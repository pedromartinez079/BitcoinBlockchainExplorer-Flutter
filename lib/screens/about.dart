
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bitcoin Blockchain Explorer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
              ),
              SizedBox(height: 8),
              Text(
                'Version 1.0.4',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface,),
              ),
              SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
              ),
              SizedBox(height: 8),
              Text(
                'Get information of bitcoin mainnet network, blocks, transactions and addresses',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface,),
              ),
              SizedBox(height: 16),
              Text(
                'Developer:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
              ),
              SizedBox(height: 8),
              Text(
                'InkaWall',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface,),
              ),
              GestureDetector(
                onTap: () async {
                  final emailUri = Uri(
                    scheme: 'mailto',
                    path: 'pedro.martinezlr@gmail.com',
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
                child: Text(
                  'pedro.martinezlr@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('https://inkawall.vercel.app/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text(
                  'https://inkawall.vercel.app/',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Legal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('https://inkawall.vercel.app/terms-and-conditions');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text(
                  'Terms of Service',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('https://inkawall.vercel.app/privacy-policy/bitcoin-blockchain-explorer');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Acknowledgments:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('https://getblock.io/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text(
                  'GetBlock',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}