xquery version "3.1";

import module namespace ucna = "http://tei-c.org/P5/Utilities" at "unicodeName.xqm";

declare namespace ucd = "http://www.unicode.org/ns/2003/ucd/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace rng = "http://relaxng.org/ns/structure/1.0";



declare default element namespace "http://www.tei-c.org/ns/1.0";

(:~
 : XQuery conversion script for automated conversion between old and new syntax.
 : Phase 3
 : @see tei/P5/spec/unicodeProp.xml
 : @see https://github.com/TEIC/TEI/issues/1805
 :
 : @author Duncan Paterson
 : @since 3.5.0
:)

(:~
 : Helper functino to test expectec output of conversion function
 :
 : @return true if conversion produces expected result
:)
declare function local:conversion-test() as xs:boolean {
let $test-data :=
<charDecl>
 <char xml:id="U4EBA-circled">
 <charName>CIRCLED IDEOGRAPH</charName>
<!-- blah blah -->
<charProp>
  <unicodeName>character-decomposition-mapping</unicodeName>
  <value>circle</value>
 </charProp>
 <charProp>
  <localName>daikanwa</localName>
  <value>36</value>
 </charProp>
 <mapping type="standard"> &#x4EBA; </mapping>
 <mapping type="PUA"> &#xE000; </mapping>
 <mapping type="PUA">U+E304</mapping>
 <mapping type="IDS">⿻人為</mapping>
  <mapping type="composed">&#x0079;&#x0307;&#x0301;</mapping>
  <mapping type="amp">&amp;#x4EBA;</mapping>
</char>
</charDecl>

let $test-result := <charDecl xmlns="http://www.tei-c.org/ns/1.0">
   <char xml:id="U4EBA-circled">
      <localProp name="name" value="CIRCLED IDEOGRAPH"/>
      <!-- blah blah -->
      <unicodeProp name="character-decomposition-mapping" value="circle"/>
      <localProp name="daikanwa" value="36"/>
      <mapping type="standard" codepoint="20154"> 人 </mapping>
      <mapping type="PUA" codepoint="57344">  </mapping>
      <mapping type="PUA">U+E304</mapping>
      <mapping type="IDS">⿻人為</mapping>
      <mapping type="composed" codepoint="121 775 769">ẏ́</mapping>
      <mapping type="amp">&amp;#x4EBA;</mapping>
   </char>
</charDecl>


return
deep-equal(local:convert-props($test-data), $test-result)

};


(:~
 : accepts arbitrary xml fragment and converts instances of 3.5.0 char / glyphProp syntax to new encoding.
 : The conditional for mapping is flitering based on Guidelines examples, in case of doubt
 : numerical codepoints will be added.
 :
 : @see https://www.w3.org/TR/xquery-31/#doc-xquery31-StringConstructor
 : @see https://github.com/TEIC/TEI/issues/1805
 : @return transformed input in new syntax
:)
declare function local:convert-props($node as node()*) as item()* {
    for $n in $node
    return
        typeswitch($n)
            case text() return ``[`{$n}`]``
            case comment() return $n
            case processing-instruction() return $n
            case element (charName) return element localProp {($n/@*, attribute name {'name'}, attribute value {$n})}
            case element (glyphName) return element localProp {($n/@*, attribute name {'name'}, attribute value {$n})}
            case element (charProp) return local:convert-props($n/node())
            case element (value) return ()
            case element (unicodeName) return element unicodeProp {($n/@*, attribute name {$n}, attribute value {$n/../value})}
            case element (localName) return element localProp {($n/@*, attribute name {$n}, attribute value {$n/../value})}
            case element (mapping) return
                if (starts-with(normalize-space($n), 'U+') or $n/@type[. = "IDS"] or starts-with(normalize-space($n), '&amp;'))
                then (element mapping {($n/@*, local:convert-props($n/node()))})
                else (element mapping {($n/@*,  attribute codepoint {string-to-codepoints(normalize-space($n))}, local:convert-props($n/node()))})
        default return element {name($n)} {($n/@*,  local:convert-props($n/node()))}

};
