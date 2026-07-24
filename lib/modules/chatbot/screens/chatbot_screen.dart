import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/modules/chatbot/services/chatbot_service.dart';

class _ChatbotEntry {
  final String text;
  final bool isMine;
  final DateTime time;
  final bool isError;

  const _ChatbotEntry({
    required this.text,
    required this.isMine,
    required this.time,
    this.isError = false,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatbotEntry> _messages = [];

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatbotEntry(
        text:
            'Hola, soy el asistente de WorkLink. Pregúntame sobre la plataforma, módulos o cómo usar la app.',
        isMine: false,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatbotEntry(text: text, isMine: true, time: DateTime.now()));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    try {
      final response = await ChatbotService.sendMessage(text);
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatbotEntry(
            text: response.reply.isNotEmpty
                ? response.reply
                : 'No se recibió una respuesta del proveedor.',
            isMine: false,
            time: DateTime.now(),
          ),
        );
        _sending = false;
      });
      _scrollToBottom();
    } on ChatbotFlowException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatbotEntry(
            text: e.toString(),
            isMine: false,
            time: DateTime.now(),
            isError: true,
          ),
        );
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatbotEntry(
            text: 'No se pudo generar la respuesta: $e',
            isMine: false,
            time: DateTime.now(),
            isError: true,
          ),
        );
        _sending = false;
      });
      _scrollToBottom();
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

  String _timeLabel(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.getTextColor()),
        ),
        title: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Style.getPrimaryColor(),
                    Style.getSecondaryColor(),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded, color: Style.white, size: 20.w),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chat IA',
                    style: Style.getHeaderTwo(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w800,
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
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              itemCount: _messages.length + (_sending ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                if (_sending && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Style.getCardColor(),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: const Radius.circular(4),
                          bottomRight: const Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Style.getPrimaryColor(),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Pensando...',
                            style: Style.getTextStyle(color: Style.getObscureTextColor()),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                return Align(
                  alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .82),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: message.isMine
                            ? Style.getPrimaryColor()
                            : (message.isError
                                ? Style.getErrorColor().withValues(alpha: .12)
                                : Style.getCardColor()),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(message.isMine ? 18 : 4),
                          bottomRight: Radius.circular(message.isMine ? 4 : 18),
                        ),
                        border: message.isError
                            ? Border.all(color: Style.getErrorColor().withValues(alpha: .24))
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: message.isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.text,
                            style: Style.getTextStyle(
                              color: message.isMine ? Style.white : Style.getTextColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _timeLabel(message.time),
                            style: Style.getTextStyle(
                              color: message.isMine
                                  ? Style.white.withValues(alpha: .75)
                                  : Style.getObscureTextColor(),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: Style.getBackgroundColor(),
              boxShadow: [
                BoxShadow(
                  color: Style.getShadowColor(),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller,
                      label: 'Pregunta a la IA',
                      hintText: 'Escribe tu pregunta...',
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Material(
                    color: Style.getPrimaryColor(),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _sending ? null : _send,
                      child: SizedBox(
                        width: 48.w,
                        height: 48.w,
                        child: Icon(Icons.send_rounded, color: Style.white, size: 18.w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
