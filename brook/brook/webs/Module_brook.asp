<title>brook</title>
<content>
<script type="text/javascript" src="/js/jquery.min.js"></script>
<script type="text/javascript" src="/js/tomato.js"></script>
<script type="text/javascript" src="/js/advancedtomato.js"></script>
<style type="text/css">
.box {
	min-width:540px;
}
</style>
	<script type="text/javascript">
		var dbus;
		get_arp_list();
		get_dbus_data();
		var _responseLen;
		var noChange = 0;
		var x = 4;
		var status_time = 1;
		var option_acl_mode = [['0', '不代理'], ['1', 'gfwlist黑名单'], ['2', '大陆白名单'], ['3', '全局模式']];
		var option_acl_mode_name = ['不代理', 'gfwlist黑名单', '大陆白名单', '全局模式'];
		var option_dns_china = [['1', '运营商DNS【自动获取】'],  ['2', '阿里DNS1【223.5.5.5】'],  ['3', '阿里DNS2【223.6.6.6】'],  ['4', '114DNS1【114.114.114.114】'],  
								['5', '114DNS1【114.114.115.115】'],  ['6', 'cnnic DNS【1.2.4.8】'],  ['7', 'cnnic DNS【210.2.4.8】'],  ['8', 'oneDNS1【112.124.47.27】'],  
								['9', 'oneDNS2【114.215.126.16】'],  ['10', '百度DNS【180.76.76.76】'],  ['11', 'DNSpod DNS【119.29.29.29】'],  ['12', '自定义']];
		var option_brook_dns_foreign = [['2', 'google dns\[8.8.8.8\]'], ['3', 'google dns\[8.8.4.4\]'], ['1', 'OpenDNS\[208.67.220.220\]'], ['4', '自定义']];
		var option_dns_foreign = [['1', 'brook_dns']];
		var option_arp_list = [];
		var option_arp_local = [];
		var option_arp_web = [];
		var softcenter = 0;

		if (typeof btoa == "Function") {
			Base64 = {
				encode: function(e) {
					return btoa(e);
				},
				decode: function(e) {
					return atob(e);
				}
			};
		} else {
			Base64 = {
				_keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
				encode: function(e) {
					var t = "";
					var n, r, i, s, o, u, a;
					var f = 0;
					e = Base64._utf8_encode(e);
					while (f < e.length) {
						n = e.charCodeAt(f++);
						r = e.charCodeAt(f++);
						i = e.charCodeAt(f++);
						s = n >> 2;
						o = (n & 3) << 4 | r >> 4;
						u = (r & 15) << 2 | i >> 6;
						a = i & 63;
						if (isNaN(r)) {
							u = a = 64
						} else if (isNaN(i)) {
							a = 64
						}
						t = t + this._keyStr.charAt(s) + this._keyStr.charAt(o) + this._keyStr.charAt(u) + this._keyStr.charAt(a)
					}
					return t
				},
				decode: function(e) {
					var t = "";
					var n, r, i;
					var s, o, u, a;
					var f = 0;
					if (typeof(e) == "undefined"){
						return t = "";
					}
					e = e.replace(/[^A-Za-z0-9\+\/\=]/g, "");
					while (f < e.length) {
						s = this._keyStr.indexOf(e.charAt(f++));
						o = this._keyStr.indexOf(e.charAt(f++));
						u = this._keyStr.indexOf(e.charAt(f++));
						a = this._keyStr.indexOf(e.charAt(f++));
						n = s << 2 | o >> 4;
						r = (o & 15) << 4 | u >> 2;
						i = (u & 3) << 6 | a;
						t = t + String.fromCharCode(n);
						if (u != 64) {
							t = t + String.fromCharCode(r)
						}
						if (a != 64) {
							t = t + String.fromCharCode(i)
						}
					}
					t = Base64._utf8_decode(t);
					return t
				},
				_utf8_encode: function(e) {
					e = e.replace(/\r\n/g, "\n");
					var t = "";
					for (var n = 0; n < e.length; n++) {
						var r = e.charCodeAt(n);
						if (r < 128) {
							t += String.fromCharCode(r)
						} else if (r > 127 && r < 2048) {
							t += String.fromCharCode(r >> 6 | 192);
							t += String.fromCharCode(r & 63 | 128)
						} else {
							t += String.fromCharCode(r >> 12 | 224);
							t += String.fromCharCode(r >> 6 & 63 | 128);
							t += String.fromCharCode(r & 63 | 128)
						}
					}
					return t
				},
				_utf8_decode: function(e) {
					var t = "";
					var n = 0;
					var r = c1 = c2 = 0;
					while (n < e.length) {
						r = e.charCodeAt(n);
						if (r < 128) {
							t += String.fromCharCode(r);
							n++
						} else if (r > 191 && r < 224) {
							c2 = e.charCodeAt(n + 1);
							t += String.fromCharCode((r & 31) << 6 | c2 & 63);
							n += 2
						} else {
							c2 = e.charCodeAt(n + 1);
							c3 = e.charCodeAt(n + 2);
							t += String.fromCharCode((r & 15) << 12 | (c2 & 63) << 6 | c3 & 63);
							n += 3
						}
					}
					return t
				}
			}
		}
		//============================================
		var brook_acl = new TomatoGrid();
		brook_acl.dataToView = function( data ) {
			if (data[0]){
				return [ "【" + data[0] + "】", data[1], data[2], option_acl_mode_name[data[3]] ];
			}else{
				if (data[1]){
					return [ "【" + data[1] + "】", data[1], data[2], option_acl_mode_name[data[3]]];
				}else{
					if (data[2]){
						return [ "【" + data[2] + "】", data[1], data[2], option_acl_mode_name[data[3]] ];
					}
				}
			}
		}
		brook_acl.fieldValuesToData = function( row ) {
			var f = fields.getAll( row );
			if (f[0].value){
				return [ f[0].value, f[1].value, f[2].value, f[3].value ];
			}else{
				if (f[1].value){
					return [ f[1].value, f[1].value, f[2].value, f[3].value ];
				}else{
					if (f[2].value){
						return [ f[2].value, f[1].value, f[2].value, f[3].value ];
					}
				}
			}
		}
    	brook_acl.onChange = function(which, cell) {
    	    return this.verifyFields((which == 'new') ? this.newEditor: this.editor, true, cell);
    	}
		brook_acl.verifyFields = function( row, quiet,cell ) {
			var f = fields.getAll( row );
			// fill the ip and mac when chose the name
			if ( $(cell).attr("id") == "_[object HTMLTableElement]_1" ) {
				if (f[0].value){
					f[1].value = option_arp_list[f[0].selectedIndex][2];
					f[2].value = option_arp_list[f[0].selectedIndex][3];
				}
			}

			//check if ip and mac column correct
			if (f[1].value && !f[2].value){
				return v_ip( f[1], quiet );
			}
			if (!f[1].value && f[2].value){
				return v_mac( f[2], quiet );
			}
			if (f[1].value && f[2].value){
				return v_ip( f[1], quiet ) || v_mac( f[2], quiet );
			}
		}
		brook_acl.alter_txt = function() {
			if (this.tb.rows.length == "4"){
				$('#footer_ip').html("<i>全部主机 - ip</i>")
				$('#footer_mac').html("<i>全部主机 - mac</i>")
			}else{
				$('#footer_ip').html("<i>其它主机 - ip</i>")
				$('#footer_mac').html("<i>其它主机 - mac</i>")
			}
		}
		brook_acl.onAdd = function() {
			var data;
			this.moving = null;
			this.rpHide();
			if (!this.verifyFields(this.newEditor, false)) return;
			data = this.fieldValuesToData(this.newEditor);
			this.insertData(1, data);
			this.disableNewEditor(false);
			this.resetNewEditor();
			this.alter_txt(); // added by sadog
		}
		brook_acl.rpDel = function(b) {
			b = PR(b);
			TGO(b).moving = null;
			b.parentNode.removeChild(b);
			this.recolor();
			this.rpHide()
			this.alter_txt(); // added by sadog
		}
		brook_acl.resetNewEditor = function() {
			var f;
			f = fields.getAll( this.newEditor );
			ferror.clearAll( f );
			f[ 0 ].value = '';
			f[ 1 ].value   = '';
			f[ 2 ].value   = '';
			f[ 3 ].value   = '1';
		}
		brook_acl.footerSet = function(c, b) {
			var f, d;
			elem.remove(this.footer);
			this.footer = f = this._insert(-1, c, b);
			//f.className = "alert alert-info";
			for (d = 0; d < f.cells.length; ++d) {
				f.cells[d].cellN = d;
				f.cells[d].onclick = function() {
					TGO(this).footerClick(this)
				}
			}
			return f
		}
		brook_acl.dataToFieldValues = function (data) {
			return [data[0], data[1], data[2], data[3]];
		}
		brook_acl.setup = function() {
			this.init( 'brook_acl_pannel', '', 254, [
			{ type: 'select',maxlen:20,options:option_arp_list},	//name
			{ type: 'text',maxlen:20},	//name
			{ type: 'text',maxlen:20},	//name
			{ type: 'select',maxlen:20,options:option_acl_mode}	//control
			] );
			this.headerSet( [ '主机别名', '主机IP地址', 'MAC地址', '访问控制'] );
			if (typeof(dbus["brook_acl_node_max"]) == "undefined"){
				this.footerSet( [ '<small id="footer_name" style="color:#1bbf35"><i>缺省规则</i></small>','<small id="footer_ip" style="color:#1bbf35"><i>全部主机 - ip</i></small>','<small id="footer_mac" style="color:#1bbf35"><i>全部主机 - mac</small></i>','<select id="_brook_acl_default_mode" name="brook_acl_default_mode" style="border: 0px solid #222;background: transparent;margin-left:-4px;padding:-0 -0;height:16px;"><option value="0">不代理</option><option value="1">gfwlist黑名单</option><option value="2">大陆白名单</option><option value="3">全局模式</option></select>']);
			}else{
				this.footerSet( [ '<small id="footer_name" style="color:#1bbf35"><i>缺省规则</i></small>','<small id="footer_ip" style="color:#1bbf35"><i>其它主机 - ip</i></small>','<small id="footer_mac" style="color:#1bbf35"><i>其它主机 - mac</small></i>','<select id="_brook_acl_default_mode" name="brook_acl_default_mode" style="border: 0px solid #222;background: transparent;margin-left:-4px;padding:-0 -0;height:16px;"><option value="0">不代理</option><option value="1">gfwlist黑名单</option><option value="2">大陆白名单</option><option value="3">全局模式</option></select>']);
			}
			
			if(typeof(dbus["brook_acl_default_mode"]) != "undefined" ){
				E("_brook_acl_default_mode").value = dbus["brook_acl_default_mode"];
			}else{
				E("_brook_acl_default_mode").value = 1;
			}
			
			for ( var i = 1; i <= dbus["brook_acl_node_max"]; i++){
				var t = [dbus["brook_acl_name_" + i ], 
						dbus["brook_acl_ip_" + i ]  || "",
						dbus["brook_acl_mac_" + i ]  || "",
						dbus["brook_acl_mode_" + i ]]
				if ( t.length == 4 ) this.insertData( -1, t );
			}
			this.recolor();
			this.showNewEditor();
			this.resetNewEditor();
		}
		//============================================
		function init_brook(){
			tabSelect('app1');
			verifyFields();
			$("#_brook_basic_log").click(
				function() {
					x = 10000000;
			});
			show_hide_panel();
			set_version();
			setTimeout("get_run_status();", 2000);
		}

		function set_version(){
			$('#_brook_version').html( '<font color="#1bbf35">Brook for LEDE ' + (dbus["brook_version"]  || "") + '</font></a>' );
		}

		function get_dbus_data(){
			$.ajax({
			  	type: "GET",
			 	url: "/_api/brook",
			  	dataType: "json",
			  	async:false,
			 	success: function(data){
			 	 	dbus = data.result[0];
			  	}
			});
		}
		
		function get_run_status(){
			if (status_time > 99999){
				return false;
			}
			var id1 = parseInt(Math.random() * 100000000);
			var postData1 = {"id": id1, "method": "brook_status.sh", "params":[2], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				data: JSON.stringify(postData1),
				dataType: "json",
				success: function(response){
					if(softcenter == 1){
						return false;
					}
					++status_time;
					if (response.result == '-2'){
						E("_brook_basic_status_foreign").innerHTML = "获取运行状态失败！";
						E("_brook_basic_status_china").innerHTML = "获取运行状态失败！";
						setTimeout("get_run_status();", 5000);
					}else{
						if(dbus["brook_basic_enable"] != "1"){
							E("_brook_basic_status_foreign").innerHTML = "国外链接 - 尚未提交，暂停获取状态！";
							E("_brook_basic_status_china").innerHTML = "国内链接 - 尚未提交，暂停获取状态！";
						}else{
							E("_brook_basic_status_foreign").innerHTML = response.result.split("@@")[0];
							E("_brook_basic_status_china").innerHTML = response.result.split("@@")[1];
						}
						setTimeout("get_run_status();", 5000);
					}
				},
				error: function(){
					if(softcenter == 1){
						return false;
					}
					E("_brook_basic_status_foreign").innerHTML = "获取运行状态失败！";
					E("_brook_basic_status_china").innerHTML = "获取运行状态失败！";
					setTimeout("get_run_status();", 5000);
				}
			});
		}

		function get_arp_list(){
			var id5 = parseInt(Math.random() * 100000000);
			var postData1 = {"id": id5, "method": "brook_getarp.sh", "params":[], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				async:true,
				cache:false,
				data: JSON.stringify(postData1),
				dataType: "json",
				success: function(response){
					if (response.result != "-1"){
						var s2 = response.result.split( '>' );
						for ( var i = 0; i < s2.length; ++i ) {
							option_arp_local[i] = [s2[ i ].split( '<' )[0], "【" + s2[ i ].split( '<' )[0] + "】", s2[ i ].split( '<' )[1], s2[ i ].split( '<' )[2]];
						}
						var node_acl = parseInt(dbus["brook_acl_node_max"]) || 0;
						for ( var i = 0; i < node_acl; ++i ) {
							option_arp_web[i] = [dbus["brook_acl_name_" + (i + 1)], "【" + dbus["brook_acl_name_" + (i + 1)] + "】", dbus["brook_acl_ip_" + (i + 1)], dbus["brook_acl_mac_" + (i + 1)]];
						}			
						option_arp_list = unique_array(option_arp_local.concat( option_arp_web ));
						brook_acl.setup();
					}
				},
				error:function(){
					brook_acl.setup();
				},
				timeout:1000
			});
		}
		function unique_array(array){
			var r = [];
			for(var i = 0, l = array.length; i < l; i++) {
				for(var j = i + 1; j < l; j++)
				if (array[i][0] === array[j][0]) j = ++i;
					r.push(array[i]);
			}
			return r.sort();;
		}

		function show_hide_panel(){
			var a  = E('_brook_basic_enable').checked;
			elem.display('brook_status_pannel', a);
			elem.display('brook_tabs', a);
			elem.display('brook_basic_tab', a);
		}

		function verifyFields(r){
			if (E("_brook_dns_plan").value == "1"){
				$('#_brook_dns_plan_txt').html("国外dns解析gfwlist名单内的国外域名，剩下的域名用国内dns解析。 ")
			}else if (E("_brook_dns_plan").value == "2"){
				$('#_brook_dns_plan_txt').html("国内dns解析cdn名单内的国内域名用，剩下的域名用国外dns解析。<font color='#FF3300'>推荐！</font> ")
			}
			// when check/uncheck brook_switch
			var a  = E('_brook_basic_enable').checked;
			if ( $(r).attr("id") == "_brook_basic_enable" ) {
				if(a){
					elem.display('brook_status_pannel', a);
					elem.display('brook_tabs', a);
					tabSelect('app1')
				}else{
					tabSelect('fuckapp')
				}
			}
			
			var b  = E('_brook_dns_china').value == '12';
			elem.display('_brook_dns_china_user', b);
			
			var c  = E('_brook_dns_foreign').value == '4';
			elem.display('_brook_dns_foreign_user', c);
			
			return true;
		}
		function tabSelect(obj){
			var tableX = ['app1-tab', 'app2-tab','app3-tab','app4-tab','app5-tab','app6-tab'];
			var boxX = ['boxr1','boxr2','boxr3','boxr4','boxr5','boxr6'];
			var appX = ['app1','app2','app3','app4','app5','app6'];
			for (var i = 0; i < tableX.length; i++){
				if(obj == appX[i]){
					$('#'+tableX[i]).addClass('active');
					$('.'+boxX[i]).show();
				}else{
					$('#'+tableX[i]).removeClass('active');
					$('.'+boxX[i]).hide();
				}
			}
			if(obj=='app6'){
				elem.display('save-button', false);
				elem.display('cancel-button', false);
				noChange=0;
				setTimeout("get_log();", 200);
			}else{
				elem.display('save-button', true);
				elem.display('cancel-button', true);
				noChange=2001;
			}
			if(obj=='fuckapp'){
				elem.display('brook_status_pannel', false);
				elem.display('brook_tabs', false);
				elem.display('brook_basic_tab', false);
				elem.display('brook_wblist_tab', false);
				elem.display('brook_dns_tab', false);
				elem.display('brook_acl_tab', false);
				elem.display('brook_log_tab', false);
				E('save-button').style.display = "";
			}
		}
		function showMsg(Outtype, title, msg){
			$('#'+Outtype).html('<h5>'+title+'</h5>'+msg+'<a class="close"><i class="icon-cancel"></i></a>');
			$('#'+Outtype).show();
		}

		function save(){
			setTimeout("tabSelect('app6')", 500);
			status_time = 999999990;
			get_run_status();
			E("_brook_basic_status_foreign").innerHTML = "国外链接 - 提交中...暂停获取状态！";
			E("_brook_basic_status_china").innerHTML = "国内链接 - 提交中...暂停获取状态！";
			var paras_chk = ["enable", "sock"];
			var paras_inp = ["brook_basic_server", "brook_basic_port", "brook_basic_password", "brook_acl_default_mode", 
							"brook_dns_plan", "brook_dns_china", "brook_dns_china_user", "brook_dns_foreign_select", "brook_dns_foreign", "brook_dns_foreign_user" ];
			// collect data from checkbox
			for (var i = 0; i < paras_chk.length; i++) {
				dbus["brook_basic_" + paras_chk[i]] = E('_brook_basic_' + paras_chk[i] ).checked ? '1':'0';
			}
			// data from other element
			for (var i = 0; i < paras_inp.length; i++) {
				if (typeof(E('_' + paras_inp[i] ).value) == "undefined"){
					dbus[paras_inp[i]] = "";
				}else{
					dbus[paras_inp[i]] = E('_' + paras_inp[i]).value;
				}
			}
			// data need base64 encode
			var paras_base64 = ["brook_wan_white_ip", "brook_wan_white_domain", "brook_wan_black_ip", "brook_wan_black_domain", "brook_dnsmasq"];
			for (var i = 0; i < paras_base64.length; i++) {
				if (typeof(E('_' + paras_base64[i] ).value) == "undefined"){
					dbus[paras_base64[i]] = "";
				}else{
					dbus[paras_base64[i]] = Base64.encode(E('_' + paras_base64[i]).value);
				}
			}
			// collect acl data from acl pannel
			var brook_acl_conf = ["brook_acl_name_", "brook_acl_ip_", "brook_acl_mac_", "brook_acl_mode_" ];
			// mark all acl data for delete first
			for ( var i = 1; i <= dbus["brook_acl_node_max"]; i++){
				for ( var j = 0; j < brook_acl_conf.length; ++j ) {
					dbus[brook_acl_conf[j] + i ] = ""
				}
			}
			var data = brook_acl.getAllData();
			if(data.length > 0){
				for ( var i = 0; i < data.length; ++i ) {
					for ( var j = 1; j < brook_acl_conf.length; ++j ) {
						dbus[brook_acl_conf[0] + (i + 1)] = data[i][0];
						dbus[brook_acl_conf[j] + (i + 1)] = data[i][j];
					}
				}
				dbus["brook_acl_node_max"] = data.length;
			}else{
				dbus["brook_acl_node_max"] = "";
			}
			// now post data
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "brook_config.sh", "params":[1], "fields": dbus};
			showMsg("msg_warring","正在提交数据！","<b>等待后台运行完毕，请不要刷新本页面！</b>");
			$.ajax({
				url: "/_api/",
				type: "POST",
				async:true,
				cache:false,
				dataType: "json",
				data: JSON.stringify(postData),
				success: function(response){
					if (response.result == id){
						if(E('_brook_basic_enable').checked){
							showMsg("msg_success","提交成功","<b>成功提交数据</b>");
							$('#msg_warring').hide();
							setTimeout("$('#msg_success').hide()", 500);
							x = 4;
							count_down_switch();
						}else{
							// when shut down ss finished, close the log tab
							$('#msg_warring').hide();
							showMsg("msg_success","提交成功","<b>brook成功关闭！</b>");
							setTimeout("$('#msg_success').hide()", 4000);
							setTimeout("tabSelect('fuckapp')", 4000);
						}
					}else{
						$('#msg_warring').hide();
						showMsg("msg_error","提交失败","<b>提交数据失败！错误代码：" + response.result + "</b>");
						setTimeout("window.location.reload()", 500);
					}
				},
				error: function(){
					showMsg("msg_error","失败","<b>当前系统存在异常查看系统日志！</b>");
					status_time = 1;
				}
			});
		}

		function get_log(){
			$.ajax({
				url: '/_temp/brook_log.txt',
				type: 'GET',
				dataType: 'html',
				async: true,
				cache:false,
				success: function(response) {
					var retArea = E("_brook_basic_log");
					if (response.search("XU6J03M6") != -1) {
						retArea.value = response.replace("XU6J03M6", " ");
						retArea.scrollTop = retArea.scrollHeight;
						return true;
					}
					if (_responseLen == response.length) {
						noChange++;
					} else {
						noChange = 0;
					}
					if (noChange > 2000) {
						//tabSelect("app1");
						return false;
					} else {
						setTimeout("get_log();", 100); //100 is radical but smooth!
					}
					retArea.value = response;
					retArea.scrollTop = retArea.scrollHeight;
					_responseLen = response.length;
				},
				error: function() {
					E("_brook_basic_log").value = "获取日志失败！";
				}
			});
		}
		function count_down_switch() {
			if (x == "0") {
				setTimeout("window.location.reload()", 500);
			}
			if (x < 0) {
				return false;
			}
				--x;
			setTimeout("count_down_switch();", 500);
		}
		function manipulate_conf(script, arg){
			var dbus3 = {};
			if(arg == 2 || arg == 4 || arg == 5){
				tabSelect("app6");
			}
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": script, "params":[arg], "fields": [] };
			$.ajax({
				type: "POST",
				url: "/_api/",
				async: true,
				cache:false,
				data: JSON.stringify(postData),
				dataType: "json",
				success: function(response){
					if (script == "brook_config.sh"){
						if(arg == 2 || arg == 4 ){
							setTimeout("window.location.reload()", 800);
						}else if (arg == 3){
							var a = document.createElement('A');
							a.href = "/files/brook_conf_backup.sh";
							a.download = 'brook_conf_backup.sh';
							document.body.appendChild(a);
							a.click();
							document.body.removeChild(a);
						}else if (arg == 5){
							setTimeout("tabSelect('app6')", 500);
							setTimeout("window.location.reload()", 800);
						}
					}
				}
			});
		}
		function restore_conf(){
			var filename = $("#file").val();
			filename = filename.split('\\');
			filename = filename[filename.length-1];
			var filelast = filename.split('.');
			filelast = filelast[filelast.length-1];
			if(filelast !='sh'){
				alert('配置文件格式不正确！');
				return false;
			}
			var formData = new FormData();
			formData.append('brook_conf_backup.sh', $('#file')[0].files[0]);
			$('.popover').html('正在恢复，请稍后……');
			//changeButton(true);
			$.ajax({
				url: '/_upload',
				type: 'POST',
				async: true,
				cache:false,
				data: formData,
				processData: false,
				contentType: false,
				complete:function(res){
					if(res.status==200){
						manipulate_conf('brook_config.sh', 4);
					}
				}
			});
		}
	</script>
	<div class="box">
		<div class="heading">
			<span id="_brook_version"></span>
			<a href="#/soft-center.asp" class="btn" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">返回</a>
		</div>
		<div class="content">
			<span class="col" style="line-height:30px;width:700px">
			Brook 是一个全平台的Socks5代理，同时支持tcp和udp代理。本插件只支持大陆白名单模式UDP转发。<br />
			你需要为 Brook 安装专用的服务端程序:<a href="https://github.com/txthinking/brook.git" target="_blank"> 【点此访问源码项目】 </a><a href="https://github.com/ToyoDAdoubi/doubi/blob/master/brook.sh" target="_blank"> 【点此访问一键服务器安装脚本】 </a>
		</div>
	</div>
	<div class="box" style="margin-top: 0px;min-width:540px;">
		<div class="heading">
		</div>
		<div class="content">
			<div id="brook_switch_pannel" class="section"></div>
			<script type="text/javascript">
				$('#brook_switch_pannel').forms([
					{ title: '代理开关', name:'brook_basic_enable',type:'checkbox',  value: dbus.brook_basic_enable == 1 }  // ==1 means default close; !=0 means default open
				]);
			</script>
			<hr />
			<fieldset id="brook_status_pannel">
				<label class="col-sm-3 control-left-label" for="_undefined">代理运行状态</label>
				<div class="col-sm-9">
					<font id="_brook_basic_status_foreign" name="brook_basic_status_foreign" color="#1bbf35">国外链接: waiting...</font>
				</div>
				<div class="col-sm-9" style="margin-top:2px">
					<font id="_brook_basic_status_china" name="brook_basic_status_china" color="#1bbf35">国内链接: waiting...</font>
				</div>
			</fieldset>
		</div>
	</div>
	<ul id="brook_tabs" class="nav nav-tabs" style="min-width:540px;">
		<li><a href="javascript:void(0);" onclick="tabSelect('app1');" id="app1-tab" class="active"><i class="icon-system"></i> 帐号设置</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app4');" id="app4-tab"><i class="icon-lock"></i> 访问控制</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app2');" id="app2-tab"><i class="icon-tools"></i> DNS设定</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app3');" id="app3-tab"><i class="icon-warning"></i> 黑白名单</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app5');" id="app5-tab"><i class="icon-wake"></i> 附加设置</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app6');" id="app6-tab"><i class="icon-hourglass"></i> 查看日志</a></li>	
	</ul>
	<div class="box boxr1" id="brook_basic_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="brook_basic_pannel" class="section"></div>
			<script type="text/javascript">
				$('#brook_basic_pannel').forms([
					{ title: 'brook 代理模式', name:'brook_acl_default_mode',type:'select', options:option_acl_mode, value:dbus.brook_acl_default_mode },
					{ title: 'brook 服务器', name:'brook_basic_server',type:'text',size: 20,value:dbus.brook_basic_server,help: '尽管支持域名格式，但是仍然建议首先使用IP地址。'},
					{ title: 'brook 端口', name:'brook_basic_port',type:'text',size: 20,value:dbus.brook_basic_port },
					{ title: 'brook 密码', name:'brook_basic_password',type:'password',size: 20,maxLength:30,value:dbus.brook_basic_password,help: '如果你的密码内有特殊字符，可能会导致密码参数不能正确的传给ss，导致启动后不能使用ss。',peekaboo: 1  },
					{ title: '允许局域网设备连接Socks5端口(1281)', name:'brook_basic_sock',type:'checkbox',  value: dbus.brook_basic_sock == 1,help: '开启后局域网内客户端都能连接本socks5代理,端口号：1281' },
				]);
			</script>
		</div>
	</div>
	<div class="box boxr2" id="brook_dns_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="brook_dns_pannel" class="section"></div>
			<script type="text/javascript">
				$('#brook_dns_pannel').forms([
					{ title: 'DNS解析偏好', name:'brook_dns_plan',type:'select',options:[['1', '国内优先'], ['2', '国外优先']], value: dbus.brook_dns_plan || "2", suffix: '<lable id="_brook_dns_plan_txt"></lable>'},
					{ title: '选择国内DNS', multi: [
						{ name: 'brook_dns_china',type:'select', options:option_dns_china, value: dbus.brook_dns_china || "1", suffix: ' &nbsp;&nbsp;' },
						{ name: 'brook_dns_china_user', type: 'text', value: dbus.brook_dns_china_user }
					]},
					// dns foreign pcap
					{ title: '选择国外DNS', multi: [
						{ name: 'brook_dns_foreign_select',type: 'select', options:option_dns_foreign, value: dbus.brook_dns_dns_foreign || "1", suffix: ' &nbsp;&nbsp;' },
						{ name: 'brook_dns_foreign',type: 'select', options:option_brook_dns_foreign, value: dbus.brook_dns_foreign || "2", suffix: ' &nbsp;&nbsp;' },
						{ name: 'brook_dns_foreign_user', type: 'text', value: dbus.brook_dns_foreign_user || "8.8.8.8:53" },
						{ suffix: '<lable>默认使用 brook 内置的DNS功能解析国外域名。</lable>' }
					]},
					{ title: '<b>自定义dnsmasq</b></br></br><font color="#B2B2B2">一行一个，错误的格式会导致dnsmasq不能启动，格式：</br>address=/koolshare.cn/2.2.2.2</br>bogus-nxdomain=220.250.64.18</br>conf-file=/koolshare/mydnsmasq.conf</font>', name: 'brook_dnsmasq', type: 'textarea', value: Base64.decode(dbus.brook_dnsmasq)||"", style: 'width: 100%; height:150px;' }
				]);
			</script>
		</div>
	</div>
	<div class="box boxr3" id="brook_wblist_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="brook_wblist_pannel" class="section"></div>
			<script type="text/javascript">
				$('#brook_wblist_pannel').forms([
					{ title: '<b>IP/CIDR白名单</b></br></br><font color="#B2B2B2">不需要加速的外网ip/cidr地址，一行一个，例如：</br>2.2.2.2</br>3.3.0.0/16</font>', name: 'brook_wan_white_ip', type: 'textarea', value: Base64.decode(dbus.brook_wan_white_ip)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>域名白名单</b></br></br><font color="#B2B2B2">不需要加速的域名，例如：</br>google.com</br>facebook.com</font>', name: 'brook_wan_white_domain', type: 'textarea', value: Base64.decode(dbus.brook_wan_white_domain)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>IP/CIDR黑名单</b></br></br><font color="#B2B2B2">需要加速的外网ip/cidr地址，一行一个，例如：</br>4.4.4.4</br>5.0.0.0/8</font>', name: 'brook_wan_black_ip', type: 'textarea', value: Base64.decode(dbus.brook_wan_black_ip)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>域名黑名单</b></br></br><font color="#B2B2B2">需要加速的域名,例如：</br>baidu.com</br>koolshare.cn</font>', name: 'brook_wan_black_domain', type: 'textarea', value: Base64.decode(dbus.brook_wan_black_domain)||"", style: 'width: 100%; height:150px;' }
				]);
			</script>
		</div>
	</div>	
	<div class="box boxr4" id="brook_acl_tab" style="margin-top: 0px;">
		<div class="content">
			<div class="tabContent">
				<table class="line-table" cellspacing=1 id="brook_acl_pannel"></table>
			</div>
			<br><hr>
		</div>
	</div>
	<div class="box boxr5" id="brook_addon_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="brook_addon_pannel" class="section"></div>
			<script type="text/javascript">
				$('#brook_addon_pannel').forms([
					{ title: 'brook 数据操作', suffix: '<button onclick="manipulate_conf(\'brook_config.sh\', 2);" class="btn btn-success">清除所有 brook 数据</button>&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="manipulate_conf(\'brook_config.sh\', 3);" class="btn btn-download">备份所有 brook 数据</button>' },
					{ title: 'brook 数据恢复', suffix: '<input type="file" id="file" size="50">&nbsp;&nbsp;<button id="upload1" type="button"  onclick="restore_conf();" class="btn btn-danger">上传并恢复 <i class="icon-cloud"></i></button>' },
					{ title: 'brook 当前版本', suffix: '<a id="brook_version" href="https://github.com/txthinking/brook/releases" target="_blank"></a>'},
					{ title: 'brook 版本升级', suffix: '<button onclick="manipulate_conf(\'brook_config.sh\', 5);" class="btn btn-download">一键升级brook 版本</button>' }
				]);
				$('#brook_version').html(dbus.brook_basic_version || "未初始化");
			</script>
		</div>
	</div>
	<div class="box boxr6" id="brook_log_tab" style="margin-top: 0px;">
		<div id="brook_log_pannel" class="content">
			<div class="section content">
				<script type="text/javascript">
					y = Math.floor(docu.getViewSize().height * 0.45);
					s = 'height:' + ((y > 300) ? y : 300) + 'px;display:block';
					$('#brook_log_pannel').append('<textarea class="as-script" name="_brook_basic_log" id="_brook_basic_log" readonly wrap="off" style="max-width:100%; min-width: 100%; margin: 0; ' + s + '" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>');
				</script>
			</div>
		</div>
	</div>
	<div id="msg_warring" class="alert alert-warning icon" style="display:none;"></div>
	<div id="msg_success" class="alert alert-success icon" style="display:none;"></div>
	<div id="msg_error" class="alert alert-error icon" style="display:none;"></div>
	<button type="button" value="Save" id="save-button" onclick="save()" class="btn btn-primary">提交 <i class="icon-check"></i></button>
	<button type="button" value="Cancel" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消 <i class="icon-cancel"></i></button>
	<script type="text/javascript">init_brook();</script>
</content>
