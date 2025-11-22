import 'package:flutter/material.dart';
import 'app_localizations.dart';

String formatTimeAgo(BuildContext context, DateTime dateTime) {
  final d = DateTime.now().difference(dateTime);
  final isTr = Localizations.localeOf(context).languageCode == 'tr';
  if (d.inMinutes < 1) return isTr ? 'şimdi' : 'now';
  if (d.inMinutes < 60) {
    final m = d.inMinutes;
    return isTr ? '$m dk önce' : '$m min ago';
  }
  if (d.inHours < 24) {
    final h = d.inHours;
    return isTr ? '$h sa önce' : '$h hours ago';
  }
  final days = d.inDays;
  return isTr ? '$days g önce' : '$days days ago';
}

String translateRelativeFromEnglish(BuildContext context, String s) {
  final isTr = Localizations.localeOf(context).languageCode == 'tr';
  if (!isTr) return s;
  return s
      .replaceAll('min ago', 'dk önce')
      .replaceAll('hour ago', 'sa önce')
      .replaceAll('hours ago', 'sa önce')
      .replaceAll('days ago', 'g önce')
      .replaceAll('day ago', 'g önce');
}


