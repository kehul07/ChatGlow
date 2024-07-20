class Message {
  late final String toId;
  late final String fromId;
  late final String msg;
  late final String read;
  late final Type type;
  late final String sent;

  Message(
      {required this.toId,
      required this.fromId,
      required this.msg,
      required this.read,
      required this.sent,
      required this.type});

  Message.fromJson(Map<String , dynamic> json){
    toId = json["toId"].toString();
    fromId = json["fromId"].toString();
    msg = json["msg"].toString();
    read = json["read"].toString();
    sent = json["sent"].toString();
    type = json["type"].toString() == Type.image.name ? Type.image : Type.text;
  }

  Map<String,dynamic> toJson(){
    final data = Map<String,dynamic>();
    data["toId"] = toId;
    data["fromId"] = fromId;
    data["msg"] = msg;
    data["read"] = read;
    data["sent"] = sent;
    data["type"] = type.name;

    return data;
  }

}

enum Type { text , image}
