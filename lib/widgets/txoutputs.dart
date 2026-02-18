
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitcoin_blockchain_explorer/widgets/card.dart';
import 'package:bitcoin_blockchain_explorer/screens/wallet.dart';
import 'package:bitcoin_blockchain_explorer/services/getblock.dart';
import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';

class TxOutputsCard extends ConsumerStatefulWidget {
  const TxOutputsCard({
    super.key,
    required this.vout,
    required this.txId,
  });

  final List<dynamic> vout;
  final String txId;

  @override
  ConsumerState<TxOutputsCard> createState() {
    return _TxOutputsCardState();
  }
}

class _TxOutputsCardState extends ConsumerState<TxOutputsCard> {
  bool _isTxOutSpentFetched = false;

  _getTxOutSpent(getblockToken, vout) async {
    for (Map t in vout) {
      final index = t['n'];
      final txOut = await fetchFromGetBlock(
        getblockToken, 'gettxout', [widget.txId, index],
      );
      if (txOut['result'] == null) {
        //Spent TxOut returns null in 'result' field
        t['spent'] = true;
      } else {
        t['spent'] = false;
      }
    }

    if (mounted) {
      setState(() {
        _isTxOutSpentFetched = true;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {       
    if (widget.vout.isEmpty) return SizedBox.shrink();

    final getblockToken = ref.watch(settingsProvider).token;

    if (!_isTxOutSpentFetched) {
      _getTxOutSpent(getblockToken, widget.vout);
    }    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.vout.map((txout) {
        List<String> lines = [];
        String? title;

        showWallet() {
          if (txout['scriptPubKey']['address'] != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => WalletScreen(address: txout['scriptPubKey']['address']),                
              )
            );
          }
        }     

        if (txout['scriptPubKey']['address'] != null) {
          title = 'Receiver Address: ${txout['scriptPubKey']['address']}';
        }
        lines.add('Value (BTC): ${txout['value']}');
        lines.add('Spent: ${txout['spent']}');
        lines.add('Index: ${txout['n']}');
        if (txout['scriptPubKey'] != null) {
          lines.add('asm: ${txout['scriptPubKey']['asm']}');
          lines.add('type: ${txout['scriptPubKey']['type']}');
          lines.add('Description: ${txout['scriptPubKey']['desc']}');
          lines.add('hex: ${txout['scriptPubKey']['hex']}');
        }

        return ExplorerElementCard(
          onTap: showWallet,
          elements: CardElements(
            title: title,
            textLines: lines,
          ),
        );
      }).toList()
    );
  }
}