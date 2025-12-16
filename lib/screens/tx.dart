import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/screens/search.dart';
import 'package:bitcoin_blockchain_explorer/widgets/card.dart';
import 'package:bitcoin_blockchain_explorer/widgets/txinputs.dart';
import 'package:bitcoin_blockchain_explorer/widgets/txoutputs.dart';

import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';
import 'package:bitcoin_blockchain_explorer/services/getblock.dart';
import 'package:intl/intl.dart';

class TxScreen extends ConsumerStatefulWidget {
  const TxScreen({
    super.key,
    required this.txHash,
  });

  final String txHash;

  @override
  ConsumerState<TxScreen> createState() {
    return _TxScreenState();
  }
}

class _TxScreenState extends ConsumerState<TxScreen> {
  Map<String, dynamic>? _txInformation;
  bool _isTxInformationFetched = false;
  Widget? _scaffoldBody;
  bool _showHex = false;
  bool _showTxInputs = false;
  bool _showTxOutputs = false;

  _getTxInformation() async {
    // Get Tx information
    try {
      final getblockToken = ref.watch(settingsProvider).token;
      final txInformation = await fetchFromGetBlock(getblockToken,
        'getrawtransaction', [widget.txHash,true]);

      setState(() {
        _txInformation = txInformation['result'];
      });
      _isTxInformationFetched = true;
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('${e.toString()}\nCheck GetBlock token!'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Hex button method
  _onHex() {
    setState(() {
      _showHex = !_showHex;
    });
  }

  // Tx Inputs button method
  _onTxInputs() {
    setState(() {
      _showTxInputs = !_showTxInputs;
    });
  }

  // Tx Outputs button method
  _onTxOutputs() {
    setState(() {
      _showTxOutputs = !_showTxOutputs;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? txInformation;
    DateTime? dateTime;
    String? formattedDate;

    if (!_isTxInformationFetched) {
      _getTxInformation();
    }

    if (_txInformation != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(_txInformation!['time'] * 1000);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);      
      // Scaffold Body if Tx information exists
      txInformation = Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tx information
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                title: 'Id: ${_txInformation!['txid']}',
                subtitle: 'Hash (Different from Id for segwit): ${_txInformation!['hash']}',
                textLines: [
                  '',
                  'Confirmations: ${_txInformation!['confirmations']}',
                  'Time UTC: $formattedDate',
                  'Block Hash: ${_txInformation!['blockhash']}',
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                // Hex button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _txInformation!['hex'] != null ?
                      _onHex : null,
                    icon: Icon(Icons.code),
                    label: Text('Hex'),
                  ),
                ),
                SizedBox(width: 5,),
                // Tx Inputs button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _txInformation!['vin'] != null ?
                      _onTxInputs : null,
                    icon: Icon(Icons.input),
                    label: Text('Tx Inputs'),
                  ),
                ),
                SizedBox(width: 5,),
                // Tx Outputs button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _txInformation!['vout'] != null ?
                      _onTxOutputs : null,
                    icon: Icon(Icons.output),
                    label: Text('Tx Outputs'),
                  ),
                ),
              ],
            ),
            // Show Hex?
            if (_showHex)
              ExplorerElementCard(
                onTap: () {},
                elements: CardElements(
                  title: 'Encoded transaction',
                  text: _txInformation!['hex']
                )
              ),
            // Show Tx Inputs?
            if (_showTxInputs)
              TxInputsCard(vin: _txInformation!['vin']),
            // Show Tx Outputs?
            if (_showTxOutputs) 
              TxOutputsCard(
                vout: _txInformation!['vout'],
                txId: _txInformation!['txid'],
              ),
          ],
        ),
      );
      setState(() {
        _scaffoldBody = txInformation;
      });
    } else {
      // Scaffolf Body if Tx information is not ready
      setState(() {
        _scaffoldBody = ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tx'),
        actions: [
          // Update screen
          IconButton(
            onPressed: () {
              setState(() {
                _isTxInformationFetched = false;
                _showHex = false;
                _showTxInputs = false;
                _showTxOutputs = false;
              });
            },
            icon: Icon(Icons.refresh),
          ),
          // Search screen
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SearchScreen(),
                )
              );
            },
            icon: Icon(Icons.search),
          ),
          // Settings screen
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SettingsScreen(),
                )
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(child: _scaffoldBody),
    );
  }
}