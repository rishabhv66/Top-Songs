xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search" at "/Marklogic/appservices/search/search.xqy";
import module namespace disp = "http://marklogic.com/MLU/top-songs/display" at "/modules/display-lib.xqy";
import module namespace option = "http://marklogic.com/MLU/top-songs/options" at "/modules/options.xqy";
import module namespace adv = "http://marklogic.com/MLU/top-songs/advanced" at "/modules/advanced-lib.xqy";

declare namespace topsong = "http://marklogic.com/MLU/top-songs";

declare variable $q-text := let $q := xdmp:get-request-field("q", "")
                            let $q := if(xdmp:get-request-field("advanced"))
                                        then adv:advanced-q()
                                        else local:add-sort($q)
                            return $q;
declare variable $search-results := search:search($q-text, local:get-options(), xs:unsignedLong(xdmp:get-request-field("start")));
declare variable $facet-size as xs:integer :=8;

(: facets :)
declare function local:facets() {
    let $log := xdmp:log(fn:concat("inside local:facets() func."))
    for $facets in $search-results/search:facet
    let $facet-count := fn:count($facets/search:facet-value)
    let $log := xdmp:log(fn:concat("$facet-count--->", $facet-count))
    let $facet-name := fn:data($facets/@name)
    return if($facet-count > 0)
        then <div class="facet">
                <div class="purplesubheading"><img src="images/checkblank.gif"/>{$facet-name}
                </div>
                {
                    let $facet-items := for $val in $facets/search:facet-value
                                            let $print := if($val/text()) then $val/text() else "Unknown"
                                            let $qtext := ($search-results/search:qtext)
                                            let $this :=
                                                if (fn:matches($val/@name/string(),"\W"))
                                                then fn:concat('"',$val/@name/string(),'"')
                                                else if ($val/@name eq "") then '""'
                                                else $val/@name/string()
                                            let $this := fn:concat($facets/@name,':',$this)
                                            let $selected := fn:matches($qtext,$this,"i")
                                            let $icon := 
                                                if($selected)
                                                then <img src="images/checkmark.gif"/>
                                                else <img src="images/checkblank.gif"/>
                                            let $link := 
                                                if($selected)
                                                then ()
                                                else if(fn:string-length($this) gt 0)
                                                        then fn:concat("(",$qtext,")"," AND ",$this)
                                                        else $this
                                            let $link := fn:encode-for-uri($link)
                                        return <div class="facet-value">{$icon}<a href="index.xqy?q={$link}">{fn:lower-case($print)}</a>
                                               </div>
                    return (<div>{$facet-items[1 to $facet-size]}</div>, if($facet-count gt $facet-size)
                                                                            then (<div class="facet-hidden" id="{$facet-name}">{$facet-items[position() gt $facet-size]}</div>,
                                                                                  <div class="facet-toggle" id="{$facet-name}_more"><img src="images/checkblank.gif"/><a href="javascript:toggle('{$facet-name}');" class="white">more...</a></div>,
                                                                                  <div class="facet-toggle-hidden" id="{$facet-name}_less"><img src="images/checkblank.gif"/><a href="javascript:toggle('{$facet-name}');" class="white">less...</a></div>)
                                                                            else())
                }
             </div>
        else <div>&#160;</div>
};

(: adds sorts to the query string :)
declare function local:add-sort($q) {
    let $sortby := local:sort-controller($q)
    return xdmp:get-request-field("q", "")(:fn:concat("sort:", $sortby):)
};

(: determines if the end user set the sort using the search field or dropdown :)
declare function local:sort-controller($q) {
    if(xdmp:get-request-field("subitbtn") or fn:not(xdmp:get-request-field("sortby")) ) 
    then
        let $order := fn:substring-after($q, "sort:")
        return $order
    else()
};

(: search result controller :)
declare function local:search-controller() {
    if(xdmp:get-request-field("bday"))
        then local:birthday()
        else local:search-results()
};

(: search nearest birthday of the star matching yours :)
declare function local:birthday() {
    let $bday := xdmp:get-request-field("bday", "")
    let $log := xdmp:log(fn:concat("local:birthday()----"))
    let $bday := if($bday castable as xs:date)
                    then $bday
                    else "invalid date format."
    let $getCloseToWeek := (for $i in fn:doc()/topsong:top-song/topsong:weeks/topsong:week[. gt $bday]
                            order by $i ascending
                           return $i)[1]
    let $uri := fn:base-uri($getCloseToWeek)
    let $songDetail := if($uri) then disp:song-detail($uri) else("No song matching your birthday")
    return $songDetail
};

(: get the options to be passed as an arg. to search:search :)
declare function local:get-options(){
    option:get-option()
};

(: search result :)
declare function local:search-results() {
    let $log := xdmp:log(fn:concat("query-text-->",xdmp:describe($q-text)))    
    let $log := xdmp:log(fn:concat("query-text",xdmp:describe($search-results)))
    let $search-snippet := for $search-result in $search-results/search:result
                            let $doc-song := fn:doc(fn:data($search-result/@uri))
                            let $docTitle := xs:string($doc-song/topsong:top-song/topsong:title)
                            let $docArtist := xs:string(fn:doc(fn:data($search-result/@uri))/topsong:top-song/topsong:artist)
                            let $totWeeks := xs:string(fn:count(fn:doc(fn:data($search-result/@uri))/topsong:top-song/topsong:weeks/topsong:week))
                            return <div>
                                    <div class="songname">{$docTitle} by {$docArtist}
                                    </div>
                                    <div class="week">ending week:{fn:data($search-result//topsong:weeks/@last)} (total weeks:{$totWeeks})
                                    </div>
                                    {
                                        if($doc-song//topsong:genres)
                                        then
                                            <div class="genre">genre:{fn:string-join($doc-song/topsong:top-song/topsong:genres/topsong:genre, ",")}</div>
                                        else()
                                    }
                                    <div class="description"></div>
                                        {disp:description($search-result)}
                                   </div>
    return if($search-snippet) then (local:pagination-after-results($search-results), $search-snippet) else <div>Sorry, no result for your request.</div>
};

(: pagination implementation :)
declare function local:pagination-after-results($results) {
    let $start := xs:unsignedLong($results/@start)
    let $length := xs:unsignedLong($results/@page-length)
    let $last := xs:unsignedLong($start + $length -1)
    let $end := $last
    let $qtext := $results/search:qtext[1]/text()
    let $total := xs:unsignedLong($results/@total)
    let $currpage := fn:ceiling($start div $length)
    let $total-pages := fn:ceiling($total div $length)
    let $previous := if (($start > 1) and ($start - $length > 0)) then fn:max((($start - $length),1)) else ()
    let $next := if ($total > $last) then $last + 1 else ()
    let $next-href := 
         if ($next) 
         then fn:concat("/index.xqy?q=",if ($qtext) then fn:encode-for-uri($qtext) else (),"&amp;start=",$next,"&amp;submitbtn=page")
         else ()
    let $previous-href := 
         if ($previous)
         then fn:concat("/index.xqy?q=",if ($qtext) then fn:encode-for-uri($qtext) else (),"&amp;start=",$previous,"&amp;submitbtn=page")
         else ()
    let $pagemin := 
        fn:min(for $i in (1 to 4)
        where ($currpage - $i) > 0
        return $currpage - $i)
    let $rangestart := fn:max(($pagemin, 1))
    let $rangeend := fn:min(($total-pages,$rangestart + 4))
    return (<div id="countdiv"><b>{$start}</b> to <b>{$end}</b> of <b>{$total}</b></div>,
            local:sort-options(),
            if($rangestart eq $rangeend)
                then()
                else
                    <div id="pagenumdiv">
                        { if ($previous) then <a href="{$previous-href}" title="View previous {$length} results"><img src="images/prevarrow.gif" class="imgbaseline"  border="0" /></a> else () }
                        {
                 for $i in ($rangestart to $rangeend)
                 let $page-start := (($length * $i) + 1) - $length
                 let $page-href := fn:concat("/index.xqy?q=",if ($qtext) then encode-for-uri($qtext) else (),"&amp;start=",$page-start,"&amp;submitbtn=page")
                 return 
                    if ($i eq $currpage) 
                    then <b>&#160;<u>{$i}</u>&#160;</b>
                    else <span class="hspace">&#160;<a href="{$page-href}">{$i}</a>&#160;</span>
                }
                { if ($next) then <a href="{$next-href}" title="View next {$length} results"><img src="images/nextarrow.gif" class="imgbaseline" border="0" /></a> else ()}
                    </div>
            )   
};

(: provides sort options :)
declare function local:sort-options() {
    <div id="sortbydiv">
             sort by: 
                <select name="sortby" id="sortby" onchange='this.form.submit()'>
                <option>relevance</option>
                <option>newest</option>
                <option>oldest</option>
                <option>artist</option>
                <option>title</option>
                </select>
                
    </div>
};

xdmp:set-response-content-type("text/html; charset=utf-8"),
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
<html>
    <title>top-songs</title>
    <head>
        <link href="css/top-songs.css" rel="stylesheet" type="text/css"/>
        <!--<script src="js/top-songs.js" type="text/javascript"/>-->
    </head>
    <body>
        <div id="wrapper">
            <div id="header"><a href="index.xqy"><img src="images/banner.jpg" width="918" height="153" border="0"/></a></div>
            <div id="leftcol">
                <img src="images/checkblank.gif"/>{local:facets()}<br />
                <br />
                <div class="purplesubheading"><img src="images/checkblank.gif"/>check your birthday!</div>
                <form name="formbday" method="get" action="index.xqy" id="formbday">
                    <img src="images/checkblank.gif" width="7"/>
                    <input type="text" name="bday" id="bday" size="15"/> 
                    <input type="submit" id="btnbday" value="go"/>
                </form>
                <div class="tinynoitalics"><img src="images/checkblank.gif"/>(e.g. 1965-10-31)</div>
            </div>
            <div id="rightcol">
                <form name="form1" method="get" action="index.xqy" id="form1">
                    <div id="searchdiv">
                        <input type="text" name="q" id="q" size="55" value="{$q-text}"/>
                        <button type="button" id="reset_button" onclick="document.getElementById('bday').value = ''; document.getElementById('q').value = ''; document.location.href='index.xqy'">x</button>&#160;
                        <input style="border:0; width:0; height:0; background-color: #A7C030" type="text" size="0" maxlength="0"/><input type="submit" id="submitbtn" name="submitbtn" value="search" />&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;<a href="advanced.xqy">advanced search</a>
                    </div>
                    <div id="detaildiv">
                        {local:search-controller()}
                    </div>
                </form>
            </div>
            <div id="footer"></div>
        </div>
    </body> 
</html>