import 'package:flutter/material.dart';
import 'package:bitcoin_blockchain_explorer/widgets/card.dart';
import 'package:bitcoin_blockchain_explorer/screens/tx.dart';

class TxInputsCard extends StatelessWidget {
  const TxInputsCard({super.key, required this.vin});

  final List<dynamic> vin;

  @override
  Widget build(BuildContext context) {
    if (vin.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: vin.map((txin) { 
        List<String> lines = [];
        String? title;
        
        showTx() {
          if (txin['txid'] != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => TxScreen(
                  txHash: txin['txid'],
                ),
              )
            );
          }
          if (txin['coinbase'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.cyanAccent,
                content: Text('Coinbase Tx -> coin generation, no inputs, miner reward, tx fees'),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }

        if (txin['coinbase'] != null) { title = 'Coinbase: ${txin['coinbase']}'; }
        if (txin['txid'] != null) { title = 'Id: ${txin['txid']}'; }
        if (txin['vout'] != null) { lines.add('Index: ${txin['vout']}'); }
        
        if (txin['scriptSig'] != null) {
          if (txin['scriptSig']['asm'] != null) { lines.add('asm: ${txin['scriptSig']['asm']}'); }
          if (txin['scriptSig']['hex'] != null) { lines.add('hex: ${txin['scriptSig']['hex']}'); }
        }

        if (txin['txinwitness'] != null) {
          for (String wit in txin['txinwitness']) {
            lines.add('Witness: $wit');
          }
        }

        return ExplorerElementCard(
          onTap: showTx,
          elements: CardElements(
              title: title,
              textLines: lines,
          ),
        );
      }).toList()
    );
  }
}