import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_contact.dart';
import '../models/payment_model.dart';
import '../services/chat_contact_service.dart';
import '../services/payment_service.dart';
import '../services/content_validation_service.dart';
import 'payment_confirmation_screens.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatContact contact;
  final String chatId;

  const ChatScreen({
    Key? key,
    required this.contact,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final PaymentService _paymentService = PaymentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSendingMessage = false;
  bool _isFinalizingWork = false;
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.getMessagesStream(widget.chatId);
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    await _chatService.markMessagesAsRead(widget.chatId);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSendingMessage) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isSendingMessage = true);

    print(
        '📤 Intentando enviar mensaje: "$messageText" al chat: ${widget.chatId}');

    try {
      await _chatService.sendMessage(widget.chatId, messageText);
      print('✅ Mensaje enviado exitosamente');

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('❌ Error enviando mensaje: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _messageController.text = messageText;
    } finally {
      setState(() => _isSendingMessage = false);
    }
  }

  Future<void> _handleFinishWork() async {
    setState(() => _isFinalizingWork = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw 'Usuario no autenticado';

      // Obtener el ID del otro usuario
      final participants = [currentUser.uid, widget.contact.userId];
      final otherUserId =
          participants.firstWhere((id) => id != currentUser.uid);

      // Crear pago pendiente
      final payment = PaymentModel(
        chatId: widget.chatId,
        serviceId: 'service_${widget.chatId}',
        providerId: currentUser.uid,
        clientId: otherUserId,
        amount: 0, // El monto debería venir del servicio
        createdAt: DateTime.now(),
        paymentMethod: 'cash',
        status: 'pending',
      );

      final paymentId = await _paymentService.createPayment(payment);

      // Enviar mensaje del sistema
      await _chatService.sendSystemMessage(
        widget.chatId,
        'El trabajador ha finalizado el trabajo. Por favor, confirma que realizaste el pago.',
        isPaymentRequest: true,
      );

      if (!mounted) return;

      // Navegar a pantalla de confirmación de pago
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreenWrapper(
            paymentId: paymentId,
            isProvider: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al finalizar trabajo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFinalizingWork = false);
      }
    }
  }

  Future<void> _handleClientConfirmPayment() async {
    try {
      final payment = await _paymentService.getPaymentByChatId(widget.chatId);

      if (payment == null) {
        throw 'No se encontró un pago pendiente';
      }

      // Enviar mensaje de confirmación
      await _chatService.sendSystemMessage(
        widget.chatId,
        'El cliente confirmó que realizó el pago.',
      );

      if (!mounted) return;

      // Navegar a pantalla de agradecimiento
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentThankYouScreen(
            payment: payment,
            isProvider: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final isProvider = currentUser !=
        null; // Aquí deberías determinar si es proveedor basado en tu lógica

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2B47),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: widget.contact.photoUrl.isNotEmpty
                  ? NetworkImage(widget.contact.photoUrl)
                  : null,
              child: widget.contact.photoUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF0A1628))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.contact.zone.isNotEmpty)
                    Text(
                      widget.contact.zone,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (isProvider)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: _isFinalizingWork ? null : _handleFinishWork,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: _isFinalizingWork
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Finalizar Trabajo'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay mensajes aún\nEnvía el primero!',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final isSystemMessage = data['isSystemMessage'] ?? false;
                    final isPaymentRequest = data['isPaymentRequest'] ?? false;
                    final isMine = data['senderId'] == currentUser?.uid;
                    final isSystem = data['senderId'] == 'system';

                    if (isSystemMessage || isSystem) {
                      return _buildSystemMessage(
                        data['text'] ?? '',
                        isPaymentRequest: isPaymentRequest,
                      );
                    }

                    return _buildMessage(
                      data['text'] ?? '',
                      isMine,
                      data['timestamp'],
                    );
                  },
                );
              },
            ),
          ),

          // Input de mensaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B47),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0A1628),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A90E2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSendingMessage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isMine, dynamic timestamp) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF4A90E2) : const Color(0xFF1A2B47),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSystemMessage(String text, {bool isPaymentRequest = false}) {
    final currentUser = _auth.currentUser;
    final isProvider = currentUser != null; // Determinar si es proveedor

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3E50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaymentRequest ? const Color(0xFF4A90E2) : Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isPaymentRequest ? Icons.payment : Icons.info_outline,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          if (isPaymentRequest && !isProvider)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleClientConfirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Ya hice el pago',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
