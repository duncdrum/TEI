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
 : XQuery conversion script for automated conversion between old and new syntax.
 : Phase 3
 : @see tei/P5/spec/unicodeProp.xml
 : @see https://github.com/TEIC/TEI/issues/1805
 :
 : @author Duncan Paterson
 : @since 3.6.0
:)
