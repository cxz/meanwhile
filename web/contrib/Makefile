
GROUP_ID = 110565

DONORS_TRANSFORM =	sf_donor.xsl
DONORS_SOURCE =		sf_donor.htm
DONORS_TARGET =		sf_donor.xml

DONORS_URL =		http://sourceforge.net/export/html_projdonors.php?group_id=$(GROUP_ID)&button=none&show_comments=1&nostyle=1


IMG_REGEX = s.<IMG \([^>]*[^/]\)>.<img \1 />.g


all:	$(DONORS_TARGET)

$(DONORS_SOURCE):
	wget -t 1 -nv -nd -N -O $(DONORS_SOURCE).tmp "$(DONORS_URL)"
	echo '<donors>' > $(DONORS_SOURCE)
	sed '$(IMG_REGEX)' $(DONORS_SOURCE).tmp >> $(DONORS_SOURCE)
	echo '</donors>' >> $(DONORS_SOURCE)
	rm -f $(DONORS_SOURCE).tmp

$(DONORS_TARGET):	$(DONORS_SOURCE) $(DONORS_TRANSFORM)
	xsltproc -o $(DONORS_TARGET) $(DONORS_TRANSFORM) $(DONORS_SOURCE)
	rm -f $(DONORS_SOURCE)

clean:
	rm -f $(DONORS_SOURCE) $(DONORS_TARGET)

