<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
		<title>SQL Runner Editable (Auto, Multi-table) - Responsive</title>
		
		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.14/codemirror.min.css" />
		<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.14/codemirror.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.14/mode/sql/sql.min.js"></script>
		
		<style>
			/* Reset & base */
			*, *::before, *::after {
				box-sizing: border-box;
			}
			body {
				font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
				background-color: #f9fafb;
				color: #222;
				margin: 1rem auto;
				max-width: 95vw;
				padding: 1rem;
			}
			
			h2 {
				color: #2c3e50;
				margin-bottom: 1rem;
				font-weight: 700;
				font-size: 1.75rem;
			}
			
			form#sqlForm {
				margin-bottom: 1.5rem;
				display: flex;
				flex-wrap: wrap;
				gap: 10px;
				align-items: center;
			}
			
			#sqlBox {
				flex-grow: 1;
				min-width: 300px;
				font-family: "Courier New", monospace;
				font-size: 1rem;
				border: 1.5px solid #ced4da;
				border-radius: 8px;
				padding: 12px;
				height: 140px;
				resize: vertical;
				box-shadow: inset 0 1px 4px rgb(0 0 0 / 0.08);
				transition: border-color 0.3s ease, box-shadow 0.3s ease;
				outline-offset: 2px;
			}
			#sqlBox:focus {
				outline: 3px solid #6366f1; /* Indigo-500 */
				border-color: #6366f1;
				box-shadow: 0 0 8px rgb(99 102 241 / 0.6);
			}
			
			form#sqlForm button {
				background-color: #6366f1;
				border: none;
				color: white;
				padding: 12px 30px;
				font-weight: 700;
				font-size: 1.1rem;
				border-radius: 10px;
				cursor: pointer;
				box-shadow: 0 5px 15px rgb(99 102 241 / 0.35);
				transition: background-color 0.3s ease, box-shadow 0.3s ease;
				user-select: none;
			}
			form#sqlForm button:hover,
			form#sqlForm button:focus {
				background-color: #4f46e5;
				box-shadow: 0 8px 25px rgb(79 70 229 / 0.55);
			}
			
			table#resultTable {
				width: 100%;
				border-collapse: separate;
				border-spacing: 0;
				border-radius: 10px;
				box-shadow: 0 3px 12px rgb(0 0 0 / 0.1);
				display: block; /* enable horizontal scroll container */
				overflow-x: auto;
				-webkit-overflow-scrolling: touch;
				min-width: 600px;
				max-height: 65vh;
				overflow: auto;
			}
			
			table#resultTable thead {
				position: sticky;
				top: 0;
				background: #4f46e5;
				z-index: 10;
			}
			
			table#resultTable thead {
				background-color: #4f46e5;
				color: white;
				font-size: 0.9rem;
			}
			
			table#resultTable thead th {
				padding: 10px 12px;
				position: relative;
				text-align: left;
				font-weight: 600;
				vertical-align: bottom;
			}
			
			table#resultTable thead th span {
				font-weight: 400;
				font-size: 0.75rem;
				color: #c7d2fe;
				display: block;
				margin-top: 2px;
			}
			
			table#resultTable tbody tr:nth-child(even) {
				background-color: #f9fafb;
			}
			
			table#resultTable tbody tr:hover {
				background-color: #e0e7ff;
			}
			
			table#resultTable tbody td {
				padding: 10px 12px;
				font-family: "Courier New", monospace;
				font-size: 0.9rem;
				min-width: 60px;
				vertical-align: middle;
				cursor: pointer;
				transition: background-color 0.2s ease;
			}
			
			table#resultTable tbody td:hover {
				background-color: #fffbeb;
			}
			
			table#resultTable tbody td[contenteditable="true"] {
				background-color: #fff7cc !important;
				outline: 3px solid #facc15;
				border-radius: 5px;
				cursor: text;
			}
			
			/* Toast notification */
			.toast {
				opacity: 0;
				transform: translateY(20px);
				transition: opacity 0.4s ease, transform 0.4s ease;
				pointer-events: none;
				z-index: 9999;
				position: fixed;
				bottom: 20px;
				right: 20px;
				background-color: #4f46e5;
				color: #fff;
				padding: 15px 28px;
				font-weight: 700;
				border-radius: 12px;
				box-shadow: 0 5px 18px rgba(79, 70, 229, 0.6);
				font-size: 1rem;
				user-select: none;
			}
			.toast.show {
				opacity: 1;
				transform: translateY(0);
				pointer-events: auto;
			}
			
			.web_title{
				font-size: 33px;
				font-weight: 600;
			}
			
			/* Responsive */
			@media (max-width: 768px) {
				form#sqlForm {
					flex-direction: column;
					gap: 16px;
					align-items: stretch;
				}
				
				#sqlBox {
					width: 100% !important;
					min-width: auto;
					height: 160px;
					font-size: 1rem;
				}
				
				form#sqlForm button {
					width: 100%;
					font-size: 1.1rem;
					padding: 14px 0;
					border-radius: 8px;
				}
				
				table#resultTable {
					max-width: 85vw;
					max-height: 60vh;
				}
				
				table#resultTable thead {
					font-size: 0.85rem;
				}
				
				table#resultTable tbody td {
					font-size: 0.85rem;
					padding: 8px 10px;
					min-width: 50px;
				}
			}
		</style>
	</head>
	<body>
		<cfoutput>
		
		<form method="post" id="sqlForm">
			<table cellpadding="0" cellspacing="0" style="width:100%;table-layout:fixed;" border="0">
				<tr>
					<td style="box-sizing:border-box;width:222px;"></td>
					<td style="box-sizing:border-box;width:auto;"></td>
				</tr>
				<tr>
					<td style="box-sizing:border-box;" valign="top">
						<font class="web_title">SQL Runner</font>
					</td>
					<td style="box-sizing:border-box;" valign="top">
						<button type="submit">Run Query</button>
					</td>
				</tr>
				<tr style="height:10px;"></tr>
				<tr>
					<td style="box-sizing:border-box;" colspan="2">
						<textarea id="sqlBox" name="sqlQuery" rows="5" placeholder="Enter your SELECT SQL here..." style="width:100%"><cfif isDefined("form.sqlQuery")>#trim(form.sqlQuery)#</cfif></textarea>
					</td>
				</tr>
			</table>
			
			
		</form>
		
		<cfset tableName = "">
		<cfset pkName = "idcode">
		<cfif isDefined("form.sqlQuery") and len(trim(form.sqlQuery))>
			<cftry>
				<cfset _sql = trim(form.sqlQuery)>
				<!--- 只允许SELECT，防止恶意输入 --->
				<cfif NOT (left(lcase(_sql), 6) eq "select")>
					<div style="color:red;">Only SELECT queries are allowed.</div>
				<cfelse>
					<!--- 自动提取表名（支持最基础的 FROM tablename 结构） --->
					<cfset regex = "from\s+([a-zA-Z0-9_]+)">
					<cfset tableMatch = reFindNoCase(regex, _sql, 1, "true")>
					<cfif structKeyExists(tableMatch,"pos") and arrayLen(tableMatch.pos) GTE 2>
						<cfset tableName = mid(_sql, tableMatch.pos[2], tableMatch.len[2])>
					</cfif>
					<cfif not len(tableName)>
						<div style="color:red;">Cannot detect table name for update. Only simple single-table queries are supported.</div>
					<cfelse>
						<input type="hidden" id="tableName" value="#tableName#">
						<cfquery name="result" datasource="#cookie.cooksql_mainsync#_active">
							<cfquery name="colMeta" datasource="#cookie.cooksql_mainsync#_active">
								SELECT
								column_name,
								data_type,
								character_maximum_length,
								numeric_precision,
								numeric_scale
								FROM information_schema.columns
								WHERE table_name = <cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar">
							</cfquery>
							<cfset colInfo = {}>
							<cfloop query="colMeta">
								<cfset col = colMeta.column_name>
								<cfset typeStr =
								colMeta.data_type EQ "character varying" ? "varchar(#colMeta.character_maximum_length#)" :
								colMeta.data_type EQ "character" ? "char(#colMeta.character_maximum_length#)" :
								colMeta.data_type EQ "numeric" ? "numeric(#colMeta.numeric_precision#,#colMeta.numeric_scale#)" :
								colMeta.data_type>
								<cfset colInfo[col] = typeStr>
							</cfloop>
							
							#preserveSingleQuotes(_sql)#
						</cfquery>
						<cfif result.recordCount EQ 0>
							<div>No data returned.</div>
						<cfelse>
							<!-- 自动检测主键列名：默认用 idcode, 没有就用第一列 -->
							<cfset hasPK = listFindNoCase(queryColumnList(result), pkName)>
							<cfif NOT hasPK>
								<cfset pkName = listFirst(queryColumnList(result))>
							</cfif>
							<input type="hidden" id="currentTableName" value="#tableName#">
							<input type="hidden" id="currentPKName" value="#pkName#">
							<div style="margin:16px 0 6px 0;">Double click cell to edit, press Enter or click elsewhere to save.</div>
							<div class="div_resultTable">
								<table id="resultTable" role="grid" aria-label="SQL query result table">
									<thead>
										<tr>
											<cfloop list="#queryColumnList(result)#" index="col">
												<th title="#colInfo[col]#">
													#col#<br />
													<span style="font-weight:normal;font-size:0.9em;">#colInfo[col]#</span>
												</th>
											</cfloop>
										</tr>
									</thead>
									<tbody>
										<cfloop query="result">
											<tr data-rowid="#result[pkName][currentRow]#">
												<cfloop list="#queryColumnList(result)#" index="col">
													<td ondblclick="makeEditable(this)" data-colname="#col#">#htmlEditFormat(result[col][currentRow])#</td>
												</cfloop>
											</tr>
										</cfloop>
									</tbody>
								</table>
							</div>
						</cfif>
					</cfif>
				</cfif>
				<cfcatch>
					<div style="color:red;">#encodeForHTML(cfcatch.message)#</div>
				</cfcatch>
			</cftry>
		</cfif>
		
		<script>
			function showToast(msg, duration = 2500) {
				const existing = document.querySelector(".toast");
				if (existing) existing.remove();
				
				const toast = document.createElement("div");
				toast.className = "toast";
				toast.textContent = msg;
				document.body.appendChild(toast);
				
				// Trigger fade-in
				requestAnimationFrame(() => toast.classList.add("show"));
				
				// Remove after duration
				setTimeout(() => {
					toast.classList.remove("show");
					toast.addEventListener("transitionend", () => toast.remove(), { once: true });
				}, duration);
			}
			
			function makeEditable(td) {
				if (td.contentEditable === "true") return;
				td.contentEditable = "true";
				td.focus();
				const original = td.textContent;
				const tr = td.closest("tr");
				const rowId = tr.dataset.rowid;
				const colName = td.dataset.colname;
				const tableName = document.getElementById("currentTableName").value;
				const pkName = document.getElementById("currentPKName").value;
				
				// 获取最大长度
				const ths = td.parentNode.parentNode.parentNode.querySelectorAll("th");
				let maxLen = 0;
				ths.forEach(th => {
					if (th.textContent.trim().startsWith(colName)) {
						const typeMatch = th.title.match(/varchar\((\d+)\)/);
						if (typeMatch) maxLen = parseInt(typeMatch[1]);
					}
				});
				
				function saveEdit(e) {
					if (e.type === "keydown" && e.key !== "Enter") return;
					e.preventDefault();
					td.contentEditable = "false";
					td.removeEventListener("blur", saveEdit);
					td.removeEventListener("keydown", saveEdit);
					let newValue = td.textContent.trim();
					if (maxLen && newValue.length > maxLen) {
						showToast("Too long! Max " + maxLen + " chars.");
						td.textContent = original;
						return;
					}
					if (newValue !== original) {
						fetch("updateCell.cfm", {
							method: "POST",
							headers: {"Content-Type": "application/x-www-form-urlencoded"},
							body: `tableName=${encodeURIComponent(tableName)}&rowId=${encodeURIComponent(rowId)}&column=${encodeURIComponent(colName)}&pkName=${encodeURIComponent(pkName)}&value=${encodeURIComponent(newValue)}`
						})
						.then(res => res.json())
						.then(data => {
							showToast(data.status === "success" ? "Update saved!" : ("Update failed: " + data.message));
							if (data.status !== "success") td.textContent = original;
							console.log(data);
						})
						.catch(err => {
							showToast("Update error");
							td.textContent = original;
							console.log(err);
						});
					}
				}
				td.addEventListener("blur", saveEdit);
				td.addEventListener("keydown", saveEdit);
			}
		</script>
	</cfoutput>
	<footer style="margin-top: 2rem; padding: 1rem 1.5rem; background: #f3f4f6; border-radius: 8px; font-size: 0.9rem; color: #4b5563; max-width: 95vw; box-shadow: 0 2px 8px rgb(0 0 0 / 0.05);">
		<h3 style="font-weight: 700; color: #374151; margin-bottom: 0.5rem;">About SQL Runner</h3>
		<p>This simple web tool allows you to run <strong>SELECT</strong> SQL queries on your connected database and view the results in an editable table.</p>
		<p><strong>How to use:</strong></p>
		<ol>
			<li>Enter a <code>SELECT</code> query targeting a single table in the text box above.</li>
			<li>Click <em>Run Query</em> to execute and display results.</li>
			<li>Double-click any cell to edit its value inline. Press Enter or click outside to save the change back to the database.</li>
		</ol>
		<p><em>Note:</em> Only simple single-table SELECT queries are supported, and updates are limited to one primary key per row.</p>
		<p style="margin-top: 1rem; font-size: 0.8rem; color: #6b7280;">© 2025 SQL Runner Project. Built for easy database querying and inline editing.</p>
	</footer>
</body>
</html>
