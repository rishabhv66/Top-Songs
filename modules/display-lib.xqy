xquery version "1.0-ml";

module namespace disp = "http://marklogic.com/MLU/top-songs/display";

import module namespace search = "http://marklogic.com/appservices/search" at "/Marklogic/appservices/search/search.xqy";

declare namespace ts = "http://marklogic.com/MLU/top-songs";

declare function disp:description($results) {
    let $res := for $result in $results/search:snippet/search:match/node()
                    return if(fn:node-name($result) eq xs:QName("search:highlight")) then <span class="highlight">{$result/text()}</span> else $result
    let $log := xdmp:log(fn:concat("description $res-->",xdmp:describe($res, 5000)))
    return $res
}; 

declare function disp:song-detail($uri) {
    let $doc := fn:doc($uri)
    return <div>
            <div class="songnamelarge">"{$doc/ts:top-song/ts:title/text()}"</div>
            {if ($doc/ts:top-song/ts:album/@url) then <div class="albumimage"><img src="{$doc/ts:top-song/ts:album/@url}"/></div> else ()}
            <div class="detailitem">#1 weeks: {fn:count($doc/ts:top-song/ts:weeks/ts:week)}</div>
            <div class="detailitem">weeks: {fn:string-join(($doc/ts:top-song/ts:weeks/ts:week), ", ")}</div>
            {if ($doc/ts:top-song/ts:genres/ts:genre) then <div class="detailitem">genre: {fn:lower-case(fn:string-join(($doc/ts:top-song/ts:genres/ts:genre), ", "))}</div> else ()}
	{if ($doc/ts:top-song/ts:artist/text()) then <div class="detailitem">artist: {$doc/ts:top-song/ts:artist/text()}</div> else ()}
	{if ($doc/ts:top-song/ts:album/text()) then <div class="detailitem">album: {$doc/ts:top-song/ts:album/text()}</div> else ()}
	{if ($doc/ts:top-song/ts:writers/ts:writer) then <div class="detailitem">writers: {fn:string-join(($doc/ts:top-song/ts:writers/ts:writer), ", ")}</div> else ()}
	{if ($doc/ts:top-song/ts:producers/ts:producer) then <div class="detailitem">producers: {fn:string-join(($doc/ts:top-song/ts:producers/ts:producer), ", ")}</div> else ()}
	{if ($doc/ts:top-song/ts:label) then <div class="detailitem">label: {$doc/ts:top-song/ts:label}</div> else ()}
	{if ($doc/ts:top-song/ts:formats/ts:format) then <div class="detailitem">formats: {fn:string-join(($doc/ts:top-song/ts:formats/ts:format), ", ")}</div> else ()} 
	{if ($doc/ts:top-song/ts:lengths/ts:length) then <div class="detailitem">lengths: {fn:string-join(($doc/ts:top-song/ts:lengths/ts:length), ", ")}</div> else ()}
	{if ($doc/ts:top-song/ts:descr) then <div class="detailitem">{$doc/ts:top-song/ts:descr}</div> else ()}
           </div>
};