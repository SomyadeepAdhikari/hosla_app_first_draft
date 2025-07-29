const express = require('express');
const router = express.Router();
const Event = require('../models/Event');
const User = require('../models/User');
const { authenticateToken } = require('../middleware/auth');
const { validateEventCreation, validatePagination, validateObjectId } = require('../middleware/validation');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Get upcoming events
router.get('/', validatePagination, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const { type, city, state } = req.query;

    const events = await Event.getUpcoming(limit, { city, state });
    
    return responseHelper.success(res, 'Events retrieved successfully', events);

  } catch (error) {
    logger.error('Get events error:', error);
    return responseHelper.serverError(res, 'Failed to get events');
  }
});

// Create event
router.post('/', authenticateToken, validateEventCreation, async (req, res) => {
  try {
    const eventData = {
      ...req.body,
      organizer: req.userId
    };

    const event = new Event(eventData);
    await event.save();

    logger.logBusinessEvent('EVENT_CREATED', req.userId, { eventId: event._id });

    return responseHelper.created(res, 'Event created successfully', event);

  } catch (error) {
    logger.error('Create event error:', error);
    return responseHelper.serverError(res, 'Failed to create event');
  }
});

// Join event
router.post('/:eventId/join', authenticateToken, validateObjectId('eventId'), async (req, res) => {
  try {
    const { eventId } = req.params;
    const { status = 'going' } = req.body;

    const event = await Event.findById(eventId);
    if (!event) {
      return responseHelper.notFound(res, 'Event not found');
    }

    await event.joinEvent(req.userId, status);

    return responseHelper.success(res, 'Successfully joined event');

  } catch (error) {
    logger.error('Join event error:', error);
    return responseHelper.serverError(res, 'Failed to join event');
  }
});

module.exports = router;
