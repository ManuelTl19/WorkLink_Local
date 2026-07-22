import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/models/chat_model.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/messages/screens/conversation_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ChatModel> _chats = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final chats = await MessageService.loadDemoChats();
    if (!mounted) return;

    setState(() {
      _chats = chats;
      _loading = false;
    });
  }

  String _timeLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _avatarColor(int index) {
    final colors = [
      Style.getPrimaryColor(),
      Style.getSecondaryColor(),
      Style.getAccentColor(),
      Style.kingBlue,
    ];
    return colors[index % colors.length];
  }

  List<ChatModel> get _filteredChats {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return _chats;

    return _chats.where((chat) {
      return chat.name.toLowerCase().contains(normalized) ||
          chat.lastMessage.toLowerCase().contains(normalized);
    }).toList();
  }

  Future<void> _openSearch() async {
    final controller = TextEditingController(text: _query);
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Style.getCardColor(),
          title: Text(
            'Buscar chats',
            style: Style.getHeaderTwo(color: Style.getTextColor()),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: Style.getTextStyle(color: Style.getTextColor()),
            decoration: InputDecoration(
              hintText: 'Nombre o mensaje',
              hintStyle: Style.getTextStyle(color: Style.getObscureTextColor()),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: Text(
                'Limpiar',
                style: Style.getTextStyle(color: Style.getObscureTextColor()),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(
                'Aplicar',
                style: Style.getTextStyle(color: Style.getPrimaryColor()),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || value == null) return;
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Chats',
          style: Style.getHeaderTwo(
            color: Style.getPrimaryColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: Icon(Icons.search_rounded, color: Style.getTextColor()),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          : ListView.separated(
              padding: EdgeInsets.all(12.w),
              itemCount: _filteredChats.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(chat: chat),
                    ),
                  ),
                  borderRadius: Style.getBorderRadius(),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Style.getCardColor(),
                      borderRadius: Style.getBorderRadius(),
                      boxShadow: [
                        BoxShadow(
                          color: Style.getShadowColor(),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 26.w,
                              backgroundColor: _avatarColor(index),
                              child: Text(
                                chat.avatarSeed.isNotEmpty
                                    ? chat.avatarSeed
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : '?',
                                style: Style.getHeaderTwo(
                                  color: Style.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (chat.isOnline)
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Style.getCardColor(),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.name,
                                      style: Style.getHeaderTwo(
                                        color: Style.getTextColor(),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _timeLabel(chat.lastMessageAt),
                                    style: Style.getHeaderThree(
                                      color: Style.getObscureTextColor(),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Style.getHeaderThree(
                                        color: Style.getObscureTextColor(),
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (chat.unreadCount > 0)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Style.getPrimaryColor(),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '${chat.unreadCount}',
                                        style: Style.getHeaderThree(
                                          color: Style.white,
                                          fontSize: 10.w,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
