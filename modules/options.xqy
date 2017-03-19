xquery version "1.0-ml";

module namespace option = "http://marklogic.com/MLU/top-songs/options";

import module namespace search = "http://marklogic.com/appservices/search" at "/Marklogic/appservices/search/search.xqy";

declare function option:get-option() as element(search:options){
    <options xmlns="http://marklogic.com/appservices/search">
             <transform-results apply="snippet"/>
             <constraint name="artist">
               <range type="xs:string" facet="true" collation="http://marklogic.com/collation/codepoint">
                 <element ns="http://marklogic.com/MLU/top-songs" name="artist"/>
                 <facet-option>limit=30</facet-option>
                 <facet-option>frequency-order</facet-option>
                 <facet-option>descending</facet-option>
               </range>
              </constraint>
              <constraint name="title">
                <range type="xs:string" facet="true" collation="http://marklogic.com/collation/codepoint">
                    <element ns="http://marklogic.com/MLU/top-songs" name="title"/>
                     <facet-option>limit=30</facet-option>
                     <facet-option>frequency-order</facet-option>
                     <facet-option>descending</facet-option>
                </range>
              </constraint>
             <constraint name="creator">
				<word>
					<field name="writers"/>
				</word>
			</constraint>
             <constraint name="decade">
				<range type="xs:date">
				<bucket ge="2010-01-01" name="2010s">2010s</bucket>
				<bucket lt="2010-01-01" ge="2000-01-01" name="2000s">2000s</bucket>
				<bucket lt="2000-01-01" ge="1990-01-01" name="1990s">1990s</bucket>
				<bucket lt="1990-01-01" ge="1980-01-01" name="1980s">1980s</bucket>
				<bucket lt="1980-01-01" ge="1970-01-01" name="1970s">1970s</bucket>
				<bucket lt="1970-01-01" ge="1960-01-01" name="1960s">1960s</bucket>
				<bucket lt="1960-01-01" ge="1950-01-01" name="1950s">1950s</bucket>
				<bucket lt="1950-01-01" name="1940s">1940s</bucket>
			<attribute ns="" name="last"/>
			<element ns="http://marklogic.com/MLU/top-songs" name="weeks"/>
			<facet-option>limit=10</facet-option>
			</range>
			</constraint>
             <return-facets>true</return-facets>
        <additional-query>
            <cts:collection-query xmlns:cts="http://marklogic.com/cts">
                <cts:uri>all</cts:uri>
            </cts:collection-query>
        </additional-query>
        <default-suggestion-source>
            <range collation="http://marklogic.com/collation/codepoint" type="xs:string" facet="true">
                <element ns="http://marklogic.com/MLU/top-songs" name="title"/>
            </range>
        </default-suggestion-source>
    </options>
};