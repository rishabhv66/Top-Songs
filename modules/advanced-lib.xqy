module namespace adv="http://marklogic.com/MLU/top-songs/advanced";
declare function advanced-q()
{
  let $keywords:=fn:tokenize(xdmp:get-request-field("keywords")," ")
  let $type:=xdmp:get-request-field("type")
  let $exclude:=fn:tokenize(xdmp:get-request-field("exclude")," ")
  let $creator := xdmp:get-request-field("creator")
  let $songTitle := xdmp:get-request-field("songtitle")
  let $keywords:=
				if($keywords)
				then if($type eq "any")
					 then fn:string-join($keywords," OR ")
					 else if($type eq "phrase")
							then fn:concat('"',fn:string-join($keywords," "),'"')
							else $keywords
				else ()
    let $log := xdmp:log(fn:concat("modules/advanced-lib.xqy-$keywords-->", $keywords[1]))				
	let $exclude:=
				if($exclude)
				then fn:string-join((for $i in $exclude
										return fn:concat("-",$i))," ")
				else ()
    let $q-text := if($creator)
                        then (let $q-text := fn:string-join(($keywords,$exclude,fn:concat("creator:", $creator))," ")
                               return $q-text)
                        else (let $q-text := fn:string-join(($keywords,$exclude)," ")
                                return $q-text)
    let $q-text := if($songTitle)
                    then (let $q-text := fn:string-join(($q-text,fn:concat("title:", $songTitle))," ")
                            return $q-text)
                    else ($q-text)
  let $log := xdmp:log(fn:concat("modules/advanced-lib.xqy-$q-text-->",$q-text))
  return $q-text
};