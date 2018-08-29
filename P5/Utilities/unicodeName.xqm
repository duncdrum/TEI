xquery version "3.1";

module namespace ucna = "http://tei-c.org/P5/Utilities";

declare namespace ucd = "http://www.unicode.org/ns/2003/ucd/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace rng = "http://relaxng.org/ns/structure/1.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";


(:~
 : we need to transform the compact schema into relax xml for processing.
 : @version 11.0.0
 : @see http://www.unicode.org/Public/11.0.0/ucd/PropertyAliases.txt
:)
declare variable $ucna:src-uri := 'http://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt';
declare variable $ucna:ucd-rnc := 'http://www.unicode.org/reports/tr42/tr42-23.rnc';
declare variable $ucna:ucd-rng := 'tr42-23.rng';
declare variable $ucna:ucd := doc($ucna:ucd-rng);
declare variable $ucna:spec := doc('../Source/Specs/unicodeName.xml');
declare variable $ucna:unihan := doc('../Source/Specs/uniHan.xml');

(:~
 : XQuery functions to construct the schema constraints for the tei:unicodeName element.
 : @see tei/P5/spec/unicodeName.xml
 :
 : @author Duncan Paterson
 : @since 3.5.0
:)

(:~
 : Parse the latest version of the propertyAliases.txt file to determin possible values for
 : tei:unicodeName
 : @param $uri the uri pointing to the latest propertyAlises.txt file
 :
 : @return a well-formed xml represnetation of all property names, e.g.
 : <root>
 :       <uniProp>
 :         <pName>cjkAccountingNumeric</pName>
 :         <pName>kAccountingNumeric</pName>
 :      </uniProp>
 :  </root>
:)
declare function ucna:txt-2-xml($uri as xs:string) as element(root) {
    let $source := unparsed-text($uri)
    
    (: make txt well-formed xml for processing :)
    let $lines := <root>{
            for $l in tokenize($source, '\n')
            return
                <line>{$l}</line>
        }</root>
    
    (: filter inlines  and empty :)
    let $filter1 := <root>{
            for $f in $lines/line
            return
                if (starts-with($f, '#') or $f eq '') then
                    ()
                else
                    (<name>{$f/text()}</name>)
        }</root>
    
    return
        <root>{
                for $x in $filter1/name
                return
                    <uniProp>{
                            for $y in tokenize($x, ';')
                            return
                                <pName>{normalize-space($y)}</pName>
                        }</uniProp>
            }</root>
};


(:~
 : turn propertyNames into valList for unicodeName
 : pure odd however, doesn't play nice with valItem on elements.
 :
 : @see TEIC/TEI#1806
 :
 : @return a single valList element containng property name values and equiv values from ucd schema
 :)


declare function ucna:write-uniName-odd() as element(valList) {
    
    let $propAlias := ucna:txt-2-xml($ucna:src-uri)//pName[2]
    
    return
        <valList
            type="closed">
            {
                for $p in $propAlias
                let $q := ucna:lookup-names($p)
                    order by $p
                return
                    <valItem
                        ident="{$p}">
                        {
                            if ($p = $q) then
                                ()
                            else
                                (<equiv
                                    name="{$q}"
                                    uri="{$ucna:ucd-rnc}"/>)
                        }
                    </valItem>
            }
        </valList>
};

(:~
 : turn propertyNames into rng:group for unicodeName
 : we're using the long canonical forms [2]
 : needs to be rng syntax since pure odd will not generate PCdata in dtds
 :
 : @see TEIC/TEI#1806
 :
 : @return a single valList element containng property name values and equiv values from ucd schema
 :)


declare function ucna:write-uniName-rng() as element(rng:group) {
    
    let $propAlias := ucna:txt-2-xml($ucna:src-uri)//pName[2]
    let $short := for $p in $propAlias
        return 
            ucna:lookup-names($p)
    let $distinct := distinct-values(($propAlias/text(), $short))
    
    return
        <rng:group>
            <rng:choice>
                { for $d in $distinct
                order by lower-case($d)
                return
                    <rng:value>{$d}</rng:value>}
            </rng:choice>
        </rng:group>
};


(:~
 : determine possible values for @version aka existing Unicode releases
 :
 : @see https://www.unicode.org/reports/tr42/
 : @version tr42-23.rnc
 :
 : @return a single valList element with valItem entries for exiting unicode versions
:)
declare function ucna:write-version-odd() as element(valList) {
    <valList
        type="closed">
        {
            for $a in $ucna:ucd//rng:attribute[@name = 'age']/rng:choice/rng:value
                order by $a
            return
                <valItem
                    ident="{$a/text()}"/>
        }
    </valList>
};


(:~
 : Helper function to get loose matching of property names working.
 : The reference file uses Snake_Case only.
 :
 : @param $string the property name alias to be checked
 :
 : @return the property name as it would appear in the reference file.
:)
declare function ucna:normalize-string($string as xs:string) as xs:string {
    lower-case(replace(normalize-space($string), '[-|\s|_]', '_'))
};

(:~
 : helper function to strip inherited namespaces from the specs
 :
 : @param $n the node to process (including children)
 :
 : @return the node without inherited namespace declarations 
:)
declare function ucna:strip-ns($n as node()) as node() {
    if ($n instance of element()) then
        (
        element {node-name($n)} {
            $n/@*,
            $n/node()/ucna:strip-ns(.)
        }
        )
    else
        if ($n instance of document-node()) then
            (
            document {ucna:strip-ns($n/node())}
            )
        else
            (
            $n
            )
};

(:~
 : Get the element/attribute name for submitted string from the RNG file.
 : xml names use both short and long forms, hence the need for this function.
 :
 : @param $alias a string loosely matching a unicode property name
 :
 : @return the xml name of the provided the property name or alias
:)
declare function ucna:lookup-names($alias as xs:string) as item()* {
    
    let $a-normal := ucna:normalize-string($alias)
    
    let $lookup-prop :=
    for $a in ucna:txt-2-xml($ucna:src-uri)//pName
    return
        if (ucna:normalize-string($a) = $a-normal)
        then
            ($a/..)
        else
            ()
    
    return
        data($ucna:ucd//*[@name = $lookup-prop//pName]/@name)
};


(:~
 : create ucd:char for validation
 :
 : @param $prop the property name string
 : @val the value to be tested
 :
 : @return a single ucd element containing a single character with the assigned properties
:)
declare function ucna:make-ucdchar($prop as xs:string, $val as xs:string) as element(ucd:ucd) {
    
    element ucd:ucd {
        element ucd:repertoir {
            element ucd:char {
                attribute cp {'12345'},
                attribute {ucna:lookup-names($prop)} {$val}
            }
        }
    }
};

(:~
 : test the valItems from unicodeName.xml file from specs to be in sync with 
 : those generated by this script; uses relative paths.
 :
 : #return  xs:boolean
:)
declare function ucna:test-specs() as xs:boolean* {
    
    let $content := for $c in $ucna:spec//tei:content/tei:valList/*
    return
        ucna:strip-ns($c)
    
    let $attDef := for $a in $ucna:spec//tei:attDef/tei:valList/*
    return
        ucna:strip-ns($a)
    
    let $han := for $h in $ucna:unihan//tei:attDef/tei:valList/*
    return
        ucna:strip-ns($h)
    
    return
        (try {
            exists($ucna:spec)
        }
        catch * {
            'could not locate the unicodeName.xml spec file, maybe it was moved?'
        },
        
        try {
            ucna:write-uniName-odd()//tei:valItem = $content
        }
        catch * {
            'the list of valid unicode name properties has changed'
        },
        
        try {
            ucna:write-version-odd()//tei:valItem = $attDef and ucna:write-version-odd()//tei:valItem = $han
        }
        catch * {
            'a new version of the Unicode Standard seem to have been released'
        })

};

(:~
 : If Saxon supports xQuery updating, this will replace the valLists 
 : in the spec files.
 : 
 : USE WITH CAUTION
:)
declare %updating function ucna:update-specs() {
    
    let $content := $ucna:spec//tei:content/tei:valList
    let $attDef := $ucna:spec//tei:attDef/tei:valList
    let $han := $ucna:unihan//tei:attDef/tei:valList/*
    
    return
        (replace node $content
            with ucna:write-uniName-odd(),
        replace node $attDef
            with ucna:write-version-odd(),
        replace node $han
            with ucna:write-version-odd())
};
