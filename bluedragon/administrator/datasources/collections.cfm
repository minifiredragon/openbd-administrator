<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    Matt Woodward - matt@mattwoodward.com

    This file is part of of the Open BlueDragon Administrator.

    The Open BlueDragon Administrator is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Administrator is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Administrator.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfsilent>
  <!--- TODO: enable "info" button to get status, or get document count to display in list of collections --->
  <!--- TODO: build simple query screen to allow users to run simple queries against collections from within the admin console --->
  <!--- TODO: investigate integration with Luke (http://www.getopt.org/luke/) to allow better insight into collections --->
  <cfparam name="searchCollectionsMessage" type="string" default="" />

  <cfset supportedLanguages = [] />
  <cfset searchCollections = [] />
  
  <cftry>
    <cfset supportedLanguages = Application.searchCollections.getSupportedLanguages() />
    <cfset searchCollections = Application.searchCollections.getSearchCollections() />
    <cfcatch type="any">
      <cfset searchCollectionsMessage = CFCATCH.Message />
      <cfset searchCollectionsMessageType = "error" />
    </cfcatch>
  </cftry>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validateAddCollectionForm(f) {
        if (f.name.value.length == 0) {
          alert("Please enter the collection name");
          return false;
        } else if (f.path.value.length == 0) {
          alert("Please enter the collection path");
          return false;
        } else if (f.language.value == "") {
          alert("Please select the collection language");
          return false;
        } else {
          return true;
        }
      }
      
      function deleteSearchCollection(collectionName) {
        if (confirm("Are you sure you want to delete this search collection?")) {
          location.replace("_controller.cfm?action=deleteSearchCollection&name=" + collectionName);
        }
      }
    </script>
    
    <div class="row">
      <div class="pull-left">
	<h2>Manage Search Collections</h2>
      </div>
      <div class="pull-right">
	<button data-controls-modal="moreInfo" data-backdrop="true" data-keyboard="true" class="btn primary">More Info</button>
      </div>
    </div>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>

    <cfif searchCollectionsMessage != "">
      <div class="alert-message #searchCollectionsMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#searchCollectionsMessage#</p>
      </div>
    </cfif>

    <cfif StructKeyExists(session, "errorFields") && IsArray(session.errorFields) && ArrayLen(session.errorFields) gt 0>
      <div class="alert-message block-message error fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<h5>The following errors occurred:</h5>
	<ul>
	  <cfloop index="i" from="1" to="#ArrayLen(session.errorFields)#">
	    <li>#session.errorFields[i][2]#</li>
	  </cfloop>
	</ul>
      </div>
    </cfif>

    <cfif ArrayLen(searchCollections) == 0>
      <p><strong><em>No search collections configured</em></strong></p>
      <cfelse>
	<table>
	  <tr bgcolor="##dedede">
	    <th colspan="5"><h5>Search Collections</h5></th>
	  </tr>
	  <tr bgcolor="##f0f0f0">
	    <th style="width:80px;">Actions</th>
	    <th>Name</th>
	    <th>Path</th>
	    <th>Language</th>
	    <th>Store Body</th>
	  </tr>
	  <cfloop index="i" from="1" to="#ArrayLen(searchCollections)#">
	    <tr bgcolor="##ffffff">
	      <td>
		<!--- <a href="_controller.cfm?action=getCollectionStatus&name=#searchCollections[i].name#">
		    <img src="../images/information.png" width="16" height="16" alt="Collection Status" title="Collection Status" border="0" />
		</a> --->
		<a href="_controller.cfm?action=showIndexForm&name=#searchCollections[i].name#">
		  <img src="../images/lightning.png" width="16" height="16" alt="Index Collection" title="Index Collection" border="0" />
		</a>
		<a href="javascript:void(0);" onclick="javascript:deleteSearchCollection('#searchCollections[i].name#')">
		  <img src="../images/cancel.png" width="16" heigth="16" alt="Delete Collection" title="Delete Collection" border="0" />
		</a>
	      </td>
	      <td>#searchCollections[i].name#</td>
	      <td>#searchCollections[i].path#</td>
	      <td>#searchCollections[i].language#</td>
	      <td>#YesNoFormat(searchCollections[i].storebody)#</td>
	    </tr>
	  </cfloop>
	</table>
    </cfif>

    <br />

    <form name="addCollection" action="_controller.cfm?action=createSearchCollection" method="post" 
	  onsubmit="javascript:return validateAddCollectionForm(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>Add Search Collection</h5></td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Collection Name</td>
	  <td>
	    <input type="text" name="name" id="name" class="span12" maxlength="50" tabindex="1" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Collection Path</td>
	  <td>
	    <input type="text" name="path" id="path" class="span12"
		   value="#expandPath('/WEB-INF/bluedragon/work/cfcollection')#" tabindex="2" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Language</td>
	  <td>
	    <select name="language" id="language" tabindex="3">
	      <cfloop index="i" from="1" to="#ArrayLen(supportedLanguages)#">
		<option value="#supportedLanguages[i]#"<cfif supportedLanguages[i] == "english"> selected="true"</cfif>>#supportedLanguages[i]#</option>
	      </cfloop>
	    </select>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Store Document Body</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="storebody" id="storebodyTrue" value="true" tabindex="4" />
	      <span>Yes</span>
	      <input type="radio" name="storebody" id="storebodyFalse" value="false" checked="true" tabindex="5" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td><input class="btn primary" type="submit" name="submit" value="Create Collection" tabindex="6" /></td>
	</tr>
      </table>
    </form>
  </cfoutput>

  <div id="moreInfo" class="modal hide fade">
    <div class="modal-header">
      <a href="##" class="close">&times;</a>
      <h3>Information Concerning Search Collections</h3>
    </div>
    <div class="modal-body">
      <ul>
	<li>
	  The Collection Path should be a complete system path that is ideally in your system's "work" directory.
	  Some examples are as follows:<br>
	  <strong>
	    Linux:<br>
	  </strong>
	  <ul>
	    <li>/opt/tomcat/webapps/openbd/WEB-INF/bluedragon/work/cfcollection</li>
	    <li>/opt/openbd/work/cfcollection</li>
	  </ul>
	  <strong>
	    Windows:<br>
	  </strong>
	  <ul>
	    <li>c:\tomcat\webapps\openbd\WEB-INF\bluedragon\work\cfcollection</li>
	    <li>c:\openbd\work\cfcollection</li>
	  </ul>
	</li>
	<li>
	  Open BlueDragon's full-text indexing and search is built on 
	  <a href="http://lucene.apache.org/" target="_blank">Apache Lucene</a>.
	</li>
	<li>
	  A full physical path starting with "/" (on Unix-based systems) or a full drive path including drive letter 
	  (on Windows systems) may be specified for the collection path.
	</li>
      </ul>
    </div>
  </div>

  <cfset StructDelete(session, "searchCollectionMessage", false) />
</cfsavecontent>
