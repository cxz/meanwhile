
FAQ_SOURCE = faq.xml
FAQ_TARGET = main.htm

FAQ_TRANSFORM = faq.xsl


all: $(FAQ_TARGET)

$(FAQ_TARGET): %.htm: %.xml $(FAQ_TRANSFORM)
	xsltproc $(FAQ_TRANSFORM) $< > $@

