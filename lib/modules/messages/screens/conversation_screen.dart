import 'dart:io';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worklink_local/modules/messages/components/message_bubble.dart';
import 'package:worklink_local/modules/messages/components/message_composer.dart';
import 'package:worklink_local/modules/messages/models/chat_model.dart';
import 'package:worklink_local/modules/messages/models/message_model.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/reports/screens/report_form_screen.dart';
import 'package:worklink_local/utils/utils.dart';

class ConversationScreen extends StatefulWidget {
  final ChatModel chat;

  const ConversationScreen({super.key, required this.chat});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

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
    try {
      final messages = await MessageService.loadDemoConversation(
        widget.chat.id,
      );
      if (!mounted) return;

      setState(() {
        _messages = messages;
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages = const [];
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar la conversación: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    try {
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el mensaje: $e')),
      );
    }
  }

  Future<void> _sendImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile == null) return;

    final filePath = pickedFile.path;
    if (filePath.isEmpty || !File(filePath).existsSync()) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: 'No fue posible cargar la imagen seleccionada.',
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    try {
      final nextId = _messages.isEmpty ? 1 : _messages.last.id + 1;
      final newMessage = await MessageService.sendDemoImageMessage(
        chatId: widget.chat.id,
        nextId: nextId,
        imageUrl: filePath,
      );

      if (!mounted) return;

      setState(() {
        _messages = [..._messages, newMessage];
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la imagen: $e')),
      );
    }
  }

  Future<void> _showMessageActions(MessageModel message) async {
    final canDelete = await MessageService.canDeleteMessage(message);
    if (!canDelete) return;

    if (!mounted) return;

    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Style.getErrorColor(),
                ),
                title: Text(
                  'Eliminar mensaje',
                  style: Style.getHeaderThree(color: Style.getTextColor()),
                ),
                subtitle: Text(
                  message.status == MessageDeliveryStatus.read
                      ? 'Ya fue leído. Solo admin puede retirarlo.'
                      : 'Retira este mensaje de la conversación.',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
                onTap: () => Navigator.pop(context, true),
              ),
              ListTile(
                leading: Icon(Icons.close_rounded, color: Style.getTextColor()),
                title: Text(
                  'Cancelar',
                  style: Style.getHeaderThree(color: Style.getTextColor()),
                ),
                onTap: () => Navigator.pop(context, false),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await MessageService.deleteMessage(message.id);
      if (!mounted) return;
      await _loadConversation();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el mensaje: $e')),
      );
    }
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

  bool get _canReportChat {
    final relatedId = widget.chat.relatedEntityId;
    final relatedType =
        widget.chat.relatedEntityType?.toLowerCase().trim() ?? '';
    if (relatedId == null || relatedId <= 0) return false;
    return relatedType == 'service_requester' ||
        relatedType == 'freelancer' ||
        relatedType == 'user';
  }

  Future<void> _reportChatUser() async {
    if (!_canReportChat) return;

    await Navigator.of(context).push(
      Transitions.slideUpTransition(
        ReportFormScreen(
          reportedUserId: widget.chat.relatedEntityId!,
          reportedUserName: widget.chat.name,
        ),
      ),
    );
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
        actions: [
          if (_canReportChat)
            IconButton(
              onPressed: _reportChatUser,
              icon: Icon(
                Icons.report_problem_rounded,
                color: Style.getTextColor(),
              ),
            ),
        ],
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
                      final message = _messages[index];
                      return GestureDetector(
                        onLongPress: () => _showMessageActions(message),
                        child: MessageBubble(message: message),
                      );
                    },
                  ),
          ),
          MessageComposer(
            controller: _composerController,
            onSend: _sendMessage,
            onPickImage: _sendImage,
            enabled: !_loading,
          ),
        ],
      ),
    );
  }
}
