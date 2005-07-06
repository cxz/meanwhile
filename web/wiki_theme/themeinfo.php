<?php

require_once('lib/Theme.php');


class Theme_Meanwhile extends Theme {

  function Theme_Meanwhile() {
    parent::Theme("meanwhile");

    /* disable the signature image */
    $this->addImageAlias('signature', false);

    $this->setLinkIcon('http');
    $this->setLinkIcon('https');
    $this->setLinkIcon('ftp');
    $this->setLinkIcon('mailto');
    $this->setLinkIcon('interwiki');
    $this->setLinkIcon('*', 'url');

    /* $this->addButtonAlias('?', 'uww'); */

    $this->setAutosplitWikiWords(true);
    $this->setAnonEditUnknownLinks(true);
    
    $this->setDateFormat("%Y-%m-%d", true);
    $this->setTimeFormat("%T");
  }

  function linkExistingWikiWord($wikiword, $linktext='', $version=false) {
    $link = parent::linkExistingWikiWord($wikiword);
    $link->setAttr('class', 'wikiknown');

    return $link;
  }

  function linkUnknownWikiWord($wikiword, $linktext='') {
    global $request;

    if(isa($wikiword, 'WikiPageName')) {
      $default_text = $wikiword->shortName;
      $wikiword = $wikiword->name;
    } else {
      $default_text = $wikiword;
    }

    if(empty($linktext))
      $linktext = $this->maybeSplitWikiWord($default_text);

    $url = WikiURL($wikiword, array('action'=>'create'));
    $link = $this->makeButton($linktext . '?', $url);
    $link->addTooltip(sprintf(_("Create: %s"), $wikiword));
    $link->setAttr('class', 'wikiunknown');

    if($request->getArg('frame'))
      $link->setAttr('target', '_top');

    return $link;
  }

  function makeActionButton($action, $label=false, $page_or_rev=false) {
    
    if(is_array($action)) {
      $attr = $action;
      $action = isset($attr['action'])? $attr['action']: 'browse';

    } else {
      $attr['action'] = $action;
    }

    if($action == 'login') {
      $attr['auth[login]'] = 1;
      $attr['action'] = 'browse';
      if(! $label) $label = 'Log In';

    } else if($action == 'logout') {
      $attr['auth[logout]'] = 1;
      $attr['action'] = 'browse';
      if(! $label) $label = 'Log Out';
    }

    return parent::makeActionButton($attr, $label, $page_or_rev);
  }

}


$WikiTheme = new Theme_Meanwhile();

?>
