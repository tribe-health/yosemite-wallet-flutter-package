import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:yosemite_wallet/models/transaction.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

class SignedTransaction extends Transaction {
  List<String> signatures;
  List<String> contextFreeData;

  SignedTransaction()
      : signatures = [],
        contextFreeData = [];

  Map<String, dynamic> toJson() {
    var json = super.toJson();

    json.addAll({'signatures': signatures, 'context_free_data': contextFreeData});

    return json;
  }

  Uint8List getDigestForSignature(String chainId) {
    ByteWriter byteWriter = ByteWriter(endian: Endian.little);

    var chainIdBytes = hex.decode(chainId);
    byteWriter.putUint8List(Uint8List.fromList(chainIdBytes));
    pack(byteWriter);

    ByteData byteData = byteWriter.done();
    Uint8List bytes = Uint8List.view(byteData.buffer, 0, byteData.lengthInBytes);
    return bytes;
  }

  @override
  void pack(ByteWriter byteWriter) {
    super.pack(byteWriter);

    for (String data in this.contextFreeData) {
      var dataAsBytes = hex.decode(data);
      byteWriter.putVariableUint(dataAsBytes.length);
      byteWriter.putUint8List(Uint8List.fromList(dataAsBytes));
    }
  }
}