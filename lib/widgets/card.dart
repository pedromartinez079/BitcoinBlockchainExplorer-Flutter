import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

class CardElements {
  final String? tip;
  final String? title;
  final String? subtitle;
  final String? text;
  final List<String>? textLines;
  final String? link1;
  final String? link1txt;
  final String? link2;
  final String? link2txt;

  const CardElements({
    this.tip,
    this.title,
    this.subtitle,
    this.text,
    this.textLines,
    this.link1,
    this.link1txt,
    this.link2,
    this.link2txt,
  });
}

class ExplorerElementCard extends StatelessWidget {
  final CardElements elements;
  final double width;
  final GestureTapCallback onTap;

  const ExplorerElementCard({
    super.key,
    required this.elements,
    this.width = 288, // ~ 18rem
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final subtitleStyle = Theme.of(context).textTheme.titleSmall;

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: Card(
          color: Theme.of(context).colorScheme.surface.withAlpha(190),
          elevation: 4.0,
          margin: const EdgeInsets.all(4.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(9.0)
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (elements.tip != null && elements.title != null)
                  Tooltip(
                    message: elements.tip!,
                    preferBelow: false,
                    child: Text(elements.title!, style: titleStyle),
                  ),
                if (elements.tip == null && elements.title != null)
                  Text(elements.title!, style: titleStyle),
        
                if (elements.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(elements.subtitle!, style: subtitleStyle),
                  ),
        
                if (elements.text != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      elements.text!,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  ),
                
                if (elements.textLines != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(                    
                      children: elements.textLines!.map((line) => 
                        Text(
                          line,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            ),
                        ),
                      ).toList(),                    
                    ),
                  ),
        
                if (elements.link1 != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: GestureDetector(
                      onTap: () => _launchUrl(elements.link1!),
                      child: Text(
                        elements.link1txt ?? elements.link1!,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
        
                if (elements.link2 != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: GestureDetector(
                      onTap: () => _launchUrl(elements.link2!),
                      child: Text(
                        elements.link2txt ?? elements.link2!,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    /*
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      // handle error, e.g., show a snackbar
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    */
  }
}