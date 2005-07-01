
/*
 // example usage //

capture = new HexDump("hex_example_1", 1);
capture.add(4, "guint32", "total message length");
capture.add(2, "guint16", "message type identifier");
capture.add(2, "guint16", "message options");
capture.add(4, "guint32", "channel ID");
capture.add(20, "string", "some text");
capture.commit();
*/



function tooltip_span(head, title, body) {
        return "<span>"
		+ "<p class=\"size\">" + head + " bytes</p>"
                + "<p class=\"title\">" + title + "</p>"
                + "<p class=\"body\">" + body + "</p>"
                + "</span>";
}


function HexDump(id, pairs) {
        var p = pairs;
        if(! p) p = 16;
        this.init(id, p);
}


HexDump.prototype = {
        init : function(id, pairs) {
                this.element = document.getElementById(id);
                this.pairs = pairs;
                this.chunks = Array();
        },

        add : function(len, title, desc) {
                var chunk = Array(len, title, desc, null);
                this.chunks.push(chunk);
        },

        commit : function() {
                var hex = this.element.innerHTML;
                var offset = 0;

		// strip off leading and trailing whitespace
		hex = hex.replace(/^\s*(.*)/, "$1");
		hex = hex.replace(/(.*?)\s*$/, "$1");

		// split on middling whitespace
                hex = hex.split(/\s+/);

                for(i = 0; i < this.chunks.length; i++) {
                        var ch = this.chunks[i];

                        var ct = "<a href=\"#\" "
                                + "id=\"" + this.element.id + "_off"
                                + offset + "\">";

                        var cs = hex.slice(offset, offset + ch[0]);

                        for(j = 0; j  < cs.length; j) {
                                ct += cs[j++];

				offset++;

				if(! (offset % this.pairs)) {
					ct += "<br />";
				} else if(j < cs.length) {
					ct += "&nbsp;";
				}	
                        }

                        ct += tooltip_span(ch[0], ch[1], ch[2]);
                        ct += "</a>";
			if(offset % this.pairs)
				ct += "&nbsp;";

                        ch[3] = ct;
                }

		cs = hex.slice(offset).join("&nbsp;");

                hex = "";
                for(i = 0; i < this.chunks.length; i++) {
                        var ch = this.chunks[i];
                        hex += ch[3];
                }

		hex += cs;

                this.element.innerHTML = hex;
        }
};


