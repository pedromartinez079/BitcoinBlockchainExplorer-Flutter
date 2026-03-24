import 'package:flutter_riverpod/legacy.dart';

class Wallet {
  final String name;
  final List<String> addresses;

  const Wallet({
    required this.name,
    required this.addresses,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'addresses': addresses,
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      name: json['name'],
      addresses: List<String>.from(json['addresses']),
    );
  }
}

class Wallets {
  final List<Wallet> wallets;

  const Wallets({
    required this.wallets,
  });
}

class WalletsNotifier extends StateNotifier<Wallets> {
  WalletsNotifier()
    : super(const Wallets(wallets: [],));

  void setWallets(Wallets wallets) {
    state = wallets;
  }

  List getWallets() { return state.wallets; }

  void addWallet(Wallet w) {    
    state.wallets.add(w);    
  }  

  List getAddresses(walletName) {
    List wList = state.wallets;
    List aList = [];
    for (Wallet w in wList) {
      if (w.name == walletName) { aList = w.addresses; }
    }
    return aList;
  }

  void addAddress(walletName, address) {
    List wList = state.wallets;
    for (Wallet w in wList) {
      if (w.name == walletName) { w.addresses.add(address); }
    }
  }

  void deleteAddress(walletName, address) {
    List wList = state.wallets;
    for (Wallet w in wList) {
      if (w.name == walletName) {
        w.addresses.removeWhere((a) => address == a);
      }
    }
  }

  void deleteWallet(walletName) {
    List wList = state.wallets;
    wList.removeWhere((w) => walletName == w.name);
  }
}

final walletsProvider =
  StateNotifierProvider<WalletsNotifier, Wallets>((ref) {
    return WalletsNotifier();
  });