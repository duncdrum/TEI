xquery version "3.1";

import module namespace ucna = "http://tei-c.org/P5/Utilities" at "unicodeName.xqm";

declare namespace unih = "http://tei-c.org/P5/Utilities/uniHan";

declare namespace ucd = "http://www.unicode.org/ns/2003/ucd/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace rng = "http://relaxng.org/ns/structure/1.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:indent "yes";
declare option output:omit-xml-declaration "yes";


(:~
 : extract uniHan property names and make valList for unicodeHan
 : @see https://www.unicode.org/reports/tr38/#AlphabeticalListing
:)
declare function unih:write-uniHan-odd() as element(valList) {
let $fields := ('kAccountingNumeric', 'kBigFive', 'kCangjie', 'kCantonese', 'kCCCII', 'kCheungBauer', 'kCheungBauerIndex', 'kCihaiT', 'kCNS1986', 'kCNS1992', 'kCompatibilityVariant', 'kCowles', 'kDaeJaweon', 'kDefinition', 'kEACC', 'kFenn', 'kFennIndex', 'kFourCornerCode', 'kFrequency', 'kGB0', 'kGB1', 'kGB3', 'kGB5', 'kGB7', 'kGB8', 'kGradeLevel', 'kGSR', 'kHangul', 'kHanYu', 'kHanyuPinlu', 'kHanyuPinyin', 'kHDZRadBreak', 'kHKGlyph', 'kHKSCS', 'kIBMJapan', 'kIICore', 'kIRG_GSource', 'kIRG_HSource', 'kIRG_JSource', 'kIRG_KPSource', 'kIRG_KSource', 'kIRG_MSource', 'kIRG_TSource', 'kIRG_USource', 'kIRG_VSource', 'kIRGDaeJaweon', 'kIRGDaiKanwaZiten', 'kIRGHanyuDaZidian', 'kIRGKangXi', 'kJa', 'kJapaneseKun', 'kJapaneseOn', 'kJinmeiyoKanji', 'kJis0', 'kJis1', 'kJIS0213', 'kJoyoKanji', 'kKangXi', 'kKarlgren', 'kKorean', 'kKoreanEducationHanja', 'kKoreanName', 'kKPS0', 'kKPS1', 'kKSC0', 'kKSC1', 'kLau', 'kMainlandTelegraph', 'kMandarin', 'kMatthews', 'kMeyerWempe', 'kMorohashi', 'kNelson', 'kOtherNumeric', 'kPhonetic', 'kPrimaryNumeric', 'kPseudoGB1', 'kRSAdobe_Japan1_6', 'kRSJapanese', 'kRSKangXi', 'kRSKanWa', 'kRSKorean', 'kRSUnicode', 'kSBGY', 'kSemanticVariant', 'kSimplifiedVariant', 'kSpecializedSemanticVariant', 'kTaiwanTelegraph', 'kTang', 'kTGH', 'kTotalStrokes', 'kTraditionalVariant', 'kVietnamese', 'kXerox', 'kXHC1983', ' kZVariant')
return
<valList
        type="closed">
        {
            for $f in $fields
                order by $f
            return
                <valItem
                    ident="{$f}">
                </valItem>
        }
</valList>
};

(:~
 : extract uniHan property names and make rng:group for unicodeHan
 : @see https://www.unicode.org/reports/tr38/#AlphabeticalListing
:)
declare function unih:write-uniHan-rng() as element(rng:group) {
let $fields := ('kAccountingNumeric', 'kBigFive', 'kCangjie', 'kCantonese', 'kCCCII', 'kCheungBauer', 'kCheungBauerIndex', 'kCihaiT', 'kCNS1986', 'kCNS1992', 'kCompatibilityVariant', 'kCowles', 'kDaeJaweon', 'kDefinition', 'kEACC', 'kFenn', 'kFennIndex', 'kFourCornerCode', 'kFrequency', 'kGB0', 'kGB1', 'kGB3', 'kGB5', 'kGB7', 'kGB8', 'kGradeLevel', 'kGSR', 'kHangul', 'kHanYu', 'kHanyuPinlu', 'kHanyuPinyin', 'kHDZRadBreak', 'kHKGlyph', 'kHKSCS', 'kIBMJapan', 'kIICore', 'kIRG_GSource', 'kIRG_HSource', 'kIRG_JSource', 'kIRG_KPSource', 'kIRG_KSource', 'kIRG_MSource', 'kIRG_TSource', 'kIRG_USource', 'kIRG_VSource', 'kIRGDaeJaweon', 'kIRGDaiKanwaZiten', 'kIRGHanyuDaZidian', 'kIRGKangXi', 'kJa', 'kJapaneseKun', 'kJapaneseOn', 'kJinmeiyoKanji', 'kJis0', 'kJis1', 'kJIS0213', 'kJoyoKanji', 'kKangXi', 'kKarlgren', 'kKorean', 'kKoreanEducationHanja', 'kKoreanName', 'kKPS0', 'kKPS1', 'kKSC0', 'kKSC1', 'kLau', 'kMainlandTelegraph', 'kMandarin', 'kMatthews', 'kMeyerWempe', 'kMorohashi', 'kNelson', 'kOtherNumeric', 'kPhonetic', 'kPrimaryNumeric', 'kPseudoGB1', 'kRSAdobe_Japan1_6', 'kRSJapanese', 'kRSKangXi', 'kRSKanWa', 'kRSKorean', 'kRSUnicode', 'kSBGY', 'kSemanticVariant', 'kSimplifiedVariant', 'kSpecializedSemanticVariant', 'kTaiwanTelegraph', 'kTang', 'kTGH', 'kTotalStrokes', 'kTraditionalVariant', 'kVietnamese', 'kXerox', 'kXHC1983', ' kZVariant')
return
        <rng:group>
            <rng:choice>
            {for $f in $fields
            order by $f
            return
                <rng:value>{$f}</rng:value>
            }
            </rng:choice>
        </rng:group>
};

(:/html/body/div/table[2 - 97]:)
(:~
 : take the html table and extract regex for schematron rules.
 : Requires manual editing of patterns, e.g. where '\/' '\x'
 : occur since these are not supported in xpath regex processing.
 :
 : @see https://www.unicode.org/reports/tr38/html/body/div/comment()[4-5]
 : START MAIN TABLE
 : @see TEIC/TEI#1805
 :
 : @return one constraintSpec element per uniHan property
 :)

(:declare function unih:write-constraints () as element(constraintSpec)* {
for $n in *:div//*:table
let $name := $n//*[. = 'Property']/..//*:strong/string()
let $pattern := $n//*[. = 'Syntax']/following-sibling::*:td/string()
order by $name
return
<constraintSpec ident="{$name}" scheme="schematron">
    <constraint>
        <sch:rule context="tei:uniHan">
            <sch:let name="input-value" value="./following-sibling::tei:value"/>
            <sch:assert test=". != {$name} or matches($input-value, '{$pattern}')">
            <sch:value-of select="$input-value"/> does not match the expected value of the unihan property.</sch:assert>
        </sch:rule>
    </constraint>
</constraintSpec>
};:)

(: tmp fix for schematron rules unihan

for $n in $ucna:unihan//constraintSpec
let $test := data($n//@test)
let $name := data($n/@ident)
let $out := replace($test, 'XXX', $name)
return
    replace node $n/constraint/sch:rule/sch:assert
        with <sch:assert test="{$out}">
            <sch:value-of select="$input-value"/> does not match the expected value of the unihan property.</sch:assert>
:)


let $data :=
<charProp>
    <uniHan>kCheungBauer</uniHan>
    <value>055/08;TLBO;mang4</value>
    <uniHan>kHDZRadBreak</uniHan>
    <value>⼀[U+2F00]:10001.010</value>
    <uniHan>kHDZRadBreak</uniHan>
    <value>⼀[U+2F00]:10001.010</value>
    <uniHan>kHanyuPinlu</uniHan>
    <value>yī(32747)</value>
    <uniHan>kTang</uniHan>
    <value>*tsit tsit</value>
    <uniHan>kVietnamese</uniHan>
    <value>thất</value>
</charProp>

return
unih:write-uniHan-rng()

(:    <op>
        <old>{$test}</old>
        <new>{replace($test, 'XXX', $name)}</new>
    </op>:)

(:translate(data($n//@test), 'xxx', data($n/@ident)):)
