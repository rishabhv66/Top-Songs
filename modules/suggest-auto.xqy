xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search" at "/Marklogic/appservices/search/search.xqy";
import module namespace option = "http://marklogic.com/MLU/top-songs/options" at "/modules/options.xqy";

declare namespace topsong = "http://marklogic.com/MLU/top-songs";

declare variable $q-text := xdmp:get-request-field("songTitle", "");
xdmp:set-response-content-type("text; charset=utf-8"),
let $search-result := search:suggest($q-text, option:get-option())
let $log := xdmp:log(fn:concat("suggest-auto.xqy-$q-text-->", $q-text))
return fn:replace(fn:string-join($search-result, ","), '"', "")