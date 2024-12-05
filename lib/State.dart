import 'package:flutter/material.dart';

class appbloc extends ChangeNotifier {
  String _rssLink="";
String  get rssLinkValue=>_rssLink;  
void  changeLink(String link){
  _rssLink=link;
  notifyListeners();
}

}
