import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/components/message_bubble.dart';
import 'package:worklink_local/modules/messages/components/message_composer.dart';
import 'package:worklink_local/modules/messages/models/chat_model.dart';
import 'package:worklink_local/modules/messages/models/message_model.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class ConversationScreen extends StatefulWidget {
  final ChatModel chat;

  const ConversationScreen({super.key, required this.chat});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final messages = await MessageService.loadDemoConversation(widget.chat.id);
    if (!mounted) return;

    setState(() {
      _messages = messages;
      _loading = false;
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    final nextId = _messages.isEmpty ? 1 : _messages.last.id + 1;
    final newMessage = await MessageService.sendDemoMessage(
      chatId: widget.chat.id,
      nextId: nextId,
      text: text,
    );

    if (!mounted) return;

    setState(() {
      _messages = [..._messages, newMessage];
      _composerController.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Color _avatarColor() {
    final colors = [
      Style.getPrimaryColor(),
      Style.getSecondaryColor(),
      Style.getAccentColor(),
      Style.kingBlue,
    ];
    return colors[widget.chat.id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.w,
              backgroundColor: _avatarColor(),
              child: Text(
                widget.chat.avatarSeed.isNotEmpty
                    ? widget.chat.avatarSeed.substring(0, 1).toUpperCase()
                    : '?',
                style: Style.getHeaderThree(
                  color: Style.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.chat.name,
                    style: Style.getHeaderTwo(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? Center(
                    child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          MessageComposer(
            controller: _composerController,
            onSend: _sendMessage,
            enabled: !_loading,
          ),
        ],
      ),
    );
  }
}
