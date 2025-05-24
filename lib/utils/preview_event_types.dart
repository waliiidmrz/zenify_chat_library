import 'package:matrix/matrix.dart';

class PreviewEventTypes {
  static const Set<String> allowed = {
    EventTypes.Message,
    EventTypes.Reaction,

    // Future: EventTypes.Sticker, EventTypes.CallInvite, etc.
  };
}
