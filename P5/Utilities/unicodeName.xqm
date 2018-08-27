xquery version "3.1";
declare namespace ucd = "http://www.unicode.org/ns/2003/ucd/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace rng = "http://relaxng.org/ns/structure/1.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare module namespace uniname = "http://tei-c.org/P5/Utilities"
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:indent "yes";
declare option output:omit-xml-declaration "yes";


(: does not seem to be supported:)
(:declare copy-namespaces no-preserve, no-inherit;:)
(:~
 : we need to transform the compact schema into relax xml for processing.
 : @version 11.0.0
 : @see http://www.unicode.org/Public/11.0.0/ucd/PropertyAliases.txt
:)
declare variable $src-uri := 'http://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt';
declare variable $ucd-rnc := 'http://www.unicode.org/reports/tr42/tr42-23.rnc';
declare variable $ucd-rng := 'tr42-23.rng';
declare variable $ucd := doc($ucd-rng);
declare variable $spec := doc('../Source/Specs/unicodeName.xml');

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
declare function uniname:txt-2-xml($uri as xs:string) as element(root) {
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
 :
 : @return a single valList element containng property name values and equiv values from ucd schema
 :)
declare function uniname:write-element-odd() as element(valList) {
    <valList
        type="closed">
        {
            for $p in uniname:txt-2-xml($src-uri)//pName[2]
                order by $p
            return
                <valItem
                    ident="{$p/text()}">
                    {
                        if ($p/text() = uniname:lookup-names($p)) then
                            ()
                        else
                            (<altIdent>{uniname:lookup-names($p)}</altIdent>)
                    }
                </valItem>
        }
    </valList>
};


(:~
 : determine possible values for @version aka existing Unicode releases
 :
 : @see https://www.unicode.org/reports/tr42/
 : @version tr42-23.rnc
 :
 : @return a single valList element with valItem entries for exiting unicode versions
:)
declare function uniname:write-version-odd() as element(valList) {
    <valList
        type="closed">
        {
            for $a in $ucd//rng:attribute[@name = 'age']/rng:choice/rng:value
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
declare function uniname:normalize-string($string as xs:string) as xs:string {
    lower-case(replace(normalize-space($string), '[-|\s|_]', '_'))
};

(:~
 : helper function to strip inherited namespaces from the specs
 :
 : @param $n the node to process (including children)
 :
 : @return the node without inherited namespace declarations 
:)
declare function uniname:strip-ns($n as node()) as node() {
    if ($n instance of element()) then
        (
        element {node-name($n)} {
            $n/@*,
            $n/node()/uniname:strip-ns(.)
        }
        )
    else
        if ($n instance of document-node()) then
            (
            document {uniname:strip-ns($n/node())}
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
declare function uniname:lookup-names($alias as xs:string) as item()* {
    
    let $a-normal := uniname:normalize-string($alias)
    
    let $lookup-prop :=
    for $a in uniname:txt-2-xml($src-uri)//pName
    return
        if (uniname:normalize-string($a) = $a-normal)
        then
            ($a/..)
        else
            ()
    
    return
        data($ucd//*[@name = $lookup-prop//pName]/@name)
};


(:~
 : create ucd:char for validation
 :
 : @param $prop the property name string
 : @val the value to be tested
 :
 : @return a single ucd element containing a single character with the assigned properties
:)
declare function uniname:make-ucdchar($prop as xs:string, $val as xs:string) as element(ucd:ucd) {
    
    element ucd:ucd {
        element ucd:repertoir {
            element ucd:char {
                attribute cp {'12345'},
                attribute {uniname:lookup-names($prop)} {$val}
            }
        }
    }
};

(:~
 : test the valItems from unicodeName.xml file from specs to be in sync with 
 : those generated by this script using relative path.
 :
 : @path to unicodeName.xml
 :
 : #return  xs:boolean
:)
declare function uniname:test-specs() as xs:boolean* {
    
    let $content := for $c in $spec//tei:content/tei:valList/*
    return
        uniname:strip-ns($c)
    let $attDef := for $a in $spec//tei:attDef/tei:valList/*
    return
        uniname:strip-ns($a)
    
    return
        (try {
            exists($spec)
        }
        catch * {
            'could not locate the unicodeName.xml spec file, maybe it was moved?'
        },
        
        try {
            uniname:write-element-odd()//tei:valItem = $content
        }
        catch * {
            'the list of valid unicode name properties has changed'
        },
        
        try {
            uniname:write-version-odd()//tei:valItem = $attDef
        }
        catch * {
            'a new version of the Unicode Standard seem to have been released'
        })

};

(:~
 : If Saxon supports xQuery updating, this will replace the valLists 
 : in the specs file.
 : 
 : USE WITH CAUTION
:)
declare %updating function uniname:update-specs() {
    
    let $content := $spec//tei:content/tei:valList
    let $attDef := $spec//tei:attDef/tei:valList
    
    return
        (replace node $content
            with uniname:write-element-odd(),
        replace node $attDef
            with uniname:write-version-odd())

};

