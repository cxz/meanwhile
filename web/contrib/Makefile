
GROUP_ID = 110565

DONORS_TRANSFORM =	sf_donor.xsl
DONORS_TARGET =		sf_donor.xml
DONORS_SOURCE =		http://sourceforge.net/export/html_projdonors.php?group_id=$(GROUP_ID)&button=none&show_comments=1&nostyle=1


IMG_REGEX = s.<IMG \([^>]*[^/]\)>.<img \1 />.g


all:	fetch

fetch:	$(DONORS_TARGET)

$(DONORS_TARGET):
	wget -t 1 -nv -nd -N -O 1.tmp "$(DONORS_SOURCE)"
	echo '<donors>' > 2.tmp
	sed '$(IMG_REGEX)' 1.tmp >> 2.tmp
	echo '</donors>' >> 2.tmp
	xsltproc -o $(DONORS_TARGET) $(DONORS_TRANSFORM) 2.tmp
	rm -f 1.tmp 2.tmp

clean:
	rm -f $(DONORS_TARGET)

