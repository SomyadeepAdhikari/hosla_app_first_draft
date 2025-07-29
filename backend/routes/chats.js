const express = require('express');
const router = express.Router();
const Chat = require('../models/Chat');
const Message = require('../models/Message');
const { authenticateToken } = require('../middleware/auth');
const { validateChatMessage, validatePagination, validateObjectId } = require('../middleware/validation');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Get user's chats
router.get('/', authenticateToken, validatePagination, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const chats = await Chat.find({
      participants: req.userId,
      isActive: true
    })
    .populate('participants', 'name profilePicture isActive')
    .populate('lastMessage')
    .sort({ lastMessageAt: -1 })
    .skip(skip)
    .limit(limit);

    const total = await Chat.countDocuments({
      participants: req.userId,
      isActive: true
    });

    return responseHelper.paginated(res, chats, { page, limit, total });

  } catch (error) {
    logger.error('Get chats error:', error);
    return responseHelper.serverError(res, 'Failed to get chats');
  }
});

// Create new chat
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { participantIds, isGroup = false, groupName } = req.body;

    if (!Array.isArray(participantIds) || participantIds.length === 0) {
      return responseHelper.error(res, 'Participant IDs are required', 400);
    }

    // Add current user to participants
    const allParticipants = [req.userId, ...participantIds];

    const chatData = {
      participants: allParticipants,
      isGroup,
      groupName: isGroup ? groupName : null,
      createdBy: req.userId
    };

    const chat = new Chat(chatData);
    await chat.save();

    return responseHelper.created(res, 'Chat created successfully', chat);

  } catch (error) {
    logger.error('Create chat error:', error);
    return responseHelper.serverError(res, 'Failed to create chat');
  }
});

// Get messages for a chat
router.get('/:chatId/messages', authenticateToken, validateObjectId('chatId'), validatePagination, async (req, res) => {
  try {
    const { chatId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;

    // Check if user is participant
    const chat = await Chat.findById(chatId);
    if (!chat || !chat.isParticipant(req.userId)) {
      return responseHelper.forbidden(res, 'Access denied to this chat');
    }

    const messages = await Message.find({
      chatId,
      isDeleted: false,
      deletedFor: { $ne: req.userId }
    })
    .populate('senderId', 'name profilePicture')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

    const total = await Message.countDocuments({
      chatId,
      isDeleted: false,
      deletedFor: { $ne: req.userId }
    });

    return responseHelper.paginated(res, messages.reverse(), { page, limit, total });

  } catch (error) {
    logger.error('Get messages error:', error);
    return responseHelper.serverError(res, 'Failed to get messages');
  }
});

// Send message
router.post('/:chatId/messages', authenticateToken, validateObjectId('chatId'), validateChatMessage, async (req, res) => {
  try {
    const { chatId } = req.params;
    const { content, messageType = 'text', location } = req.body;

    // Check if user is participant
    const chat = await Chat.findById(chatId);
    if (!chat || !chat.isParticipant(req.userId)) {
      return responseHelper.forbidden(res, 'Access denied to this chat');
    }

    const messageData = {
      chatId,
      senderId: req.userId,
      messageType,
      content: content?.trim(),
      location
    };

    const message = new Message(messageData);
    await message.save();

    // Update chat's last message
    chat.lastMessage = message._id;
    chat.lastMessageAt = new Date();
    await chat.save();

    await message.populate('senderId', 'name profilePicture');

    return responseHelper.created(res, 'Message sent successfully', message);

  } catch (error) {
    logger.error('Send message error:', error);
    return responseHelper.serverError(res, 'Failed to send message');
  }
});

module.exports = router;
