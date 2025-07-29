const express = require('express');
const router = express.Router();
const Post = require('../models/Post');
const User = require('../models/User');
const HoslaPoint = require('../models/HoslaPoint');
const Notification = require('../models/Notification');
const { authenticateToken, optionalAuth, checkOwnership } = require('../middleware/auth');
const { validatePostCreation, validateComment, validatePagination, validateObjectId } = require('../middleware/validation');
const { uploadPostMedia } = require('../config/cloudinary');
const { postCreationLimiter } = require('../middleware/rateLimiting');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Get posts for feed
router.get('/', optionalAuth, validatePagination, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { userId, mediaType, trending } = req.query;

    let query = {
      isVisible: true,
      moderationStatus: 'approved'
    };

    // Filter by user if specified
    if (userId) {
      query.userId = userId;
    }

    // Filter by media type if specified
    if (mediaType) {
      query.mediaType = mediaType;
    }

    let posts;
    let total;

    if (trending === 'true') {
      // Get trending posts
      posts = await Post.getTrending(limit);
      total = posts.length;
      
      // Populate user details for trending posts
      await Post.populate(posts, {
        path: 'userId',
        select: 'name profilePicture isActive'
      });
    } else {
      // Regular feed with pagination
      posts = await Post.find(query)
        .populate('userId', 'name profilePicture isActive')
        .populate('comments.userId', 'name profilePicture')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit);

      total = await Post.countDocuments(query);
    }

    // Add interaction data for authenticated users
    const postsWithInteractions = posts.map(post => {
      const postObj = post.toObject();
      
      if (req.userId) {
        postObj.isLiked = post.isLikedBy(req.userId);
        postObj.hasViewed = post.views.some(view => view.userId.equals(req.userId));
      } else {
        postObj.isLiked = false;
        postObj.hasViewed = false;
      }

      return postObj;
    });

    return responseHelper.paginated(res, postsWithInteractions, { page, limit, total });

  } catch (error) {
    logger.error('Get posts error:', error);
    return responseHelper.serverError(res, 'Failed to get posts');
  }
});

// Create new post
router.post('/', authenticateToken, postCreationLimiter, uploadPostMedia.single('media'), validatePostCreation, async (req, res) => {
  try {
    const { content, tags } = req.body;
    let { mediaType } = req.body;

    // Determine media type from uploaded file
    if (req.file) {
      if (req.file.mimetype.startsWith('image/')) {
        mediaType = 'image';
      } else if (req.file.mimetype.startsWith('video/')) {
        mediaType = 'video';
      } else if (req.file.mimetype.startsWith('audio/')) {
        mediaType = 'audio';
      }
    } else {
      mediaType = 'text';
    }

    const postData = {
      userId: req.userId,
      content: content?.trim(),
      mediaType,
      mediaUrl: req.file?.path || null,
      mediaDuration: req.body.mediaDuration || null,
      mediaSize: req.file?.size || null,
      tags: tags ? (Array.isArray(tags) ? tags : [tags]) : []
    };

    const post = new Post(postData);
    await post.save();

    // Populate user details
    await post.populate('userId', 'name profilePicture');

    // Award points for creating post
    await HoslaPoint.awardPoints(
      req.userId,
      'post_created',
      10,
      'Created a post',
      post._id,
      'Post'
    );

    logger.logBusinessEvent('POST_CREATED', req.userId, { 
      postId: post._id, 
      mediaType,
      hasMedia: !!req.file 
    });

    return responseHelper.created(res, 'Post created successfully', {
      id: post._id,
      content: post.content,
      mediaType: post.mediaType,
      mediaUrl: post.mediaUrl,
      tags: post.tags,
      user: post.userId,
      createdAt: post.createdAt
    });

  } catch (error) {
    logger.error('Create post error:', error);
    return responseHelper.serverError(res, 'Failed to create post');
  }
});

// Get single post
router.get('/:postId', optionalAuth, validateObjectId('postId'), async (req, res) => {
  try {
    const { postId } = req.params;

    const post = await Post.findById(postId)
      .populate('userId', 'name profilePicture isActive')
      .populate('comments.userId', 'name profilePicture');

    if (!post || !post.isVisible || post.moderationStatus !== 'approved') {
      return responseHelper.notFound(res, 'Post not found');
    }

    // Record view if user is authenticated
    if (req.userId) {
      await post.addView(req.userId);
    }

    const postObj = post.toObject();
    if (req.userId) {
      postObj.isLiked = post.isLikedBy(req.userId);
    } else {
      postObj.isLiked = false;
    }

    return responseHelper.success(res, 'Post retrieved successfully', postObj);

  } catch (error) {
    logger.error('Get post error:', error);
    return responseHelper.serverError(res, 'Failed to get post');
  }
});

// Update post
router.put('/:postId', authenticateToken, validateObjectId('postId'), checkOwnership('Post'), async (req, res) => {
  try {
    const { content, tags } = req.body;
    const post = req.resource; // From checkOwnership middleware

    // Update allowed fields
    if (content !== undefined) {
      post.content = content.trim();
    }
    if (tags !== undefined) {
      post.tags = Array.isArray(tags) ? tags : [tags];
    }

    await post.save();

    logger.logBusinessEvent('POST_UPDATED', req.userId, { postId: post._id });

    return responseHelper.success(res, 'Post updated successfully', {
      id: post._id,
      content: post.content,
      tags: post.tags,
      updatedAt: post.updatedAt
    });

  } catch (error) {
    logger.error('Update post error:', error);
    return responseHelper.serverError(res, 'Failed to update post');
  }
});

// Delete post
router.delete('/:postId', authenticateToken, validateObjectId('postId'), checkOwnership('Post'), async (req, res) => {
  try {
    const post = req.resource; // From checkOwnership middleware

    // Soft delete - just hide the post
    post.isVisible = false;
    await post.save();

    logger.logBusinessEvent('POST_DELETED', req.userId, { postId: post._id });

    return responseHelper.success(res, 'Post deleted successfully');

  } catch (error) {
    logger.error('Delete post error:', error);
    return responseHelper.serverError(res, 'Failed to delete post');
  }
});

// Like/Unlike post
router.post('/:postId/like', authenticateToken, validateObjectId('postId'), async (req, res) => {
  try {
    const { postId } = req.params;

    const post = await Post.findById(postId)
      .populate('userId', 'name');

    if (!post || !post.isVisible || post.moderationStatus !== 'approved') {
      return responseHelper.notFound(res, 'Post not found');
    }

    const isLiked = post.isLikedBy(req.userId);
    
    if (isLiked) {
      // Unlike
      await post.removeLike(req.userId);
    } else {
      // Like
      await post.addLike(req.userId);
      
      // Award points to post creator
      if (!post.userId._id.equals(req.userId)) {
        await HoslaPoint.awardPoints(
          post.userId._id,
          'post_liked',
          2,
          'Someone liked your post',
          post._id,
          'Post'
        );

        // Create notification for post owner
        await Notification.createPostLikeNotification(
          post.userId._id,
          req.userId,
          post._id
        );
      }
    }

    await post.save();

    logger.logBusinessEvent(isLiked ? 'POST_UNLIKED' : 'POST_LIKED', req.userId, { 
      postId: post._id,
      postOwnerId: post.userId._id 
    });

    return responseHelper.success(res, isLiked ? 'Post unliked' : 'Post liked', {
      isLiked: !isLiked,
      likeCount: post.likeCount
    });

  } catch (error) {
    logger.error('Like post error:', error);
    return responseHelper.serverError(res, 'Failed to like post');
  }
});

// Add comment to post
router.post('/:postId/comments', authenticateToken, validateObjectId('postId'), validateComment, async (req, res) => {
  try {
    const { postId } = req.params;
    const { content } = req.body;

    const post = await Post.findById(postId)
      .populate('userId', 'name');

    if (!post || !post.isVisible || post.moderationStatus !== 'approved') {
      return responseHelper.notFound(res, 'Post not found');
    }

    await post.addComment(req.userId, content.trim());
    await post.populate('comments.userId', 'name profilePicture');

    // Award points to commenter
    await HoslaPoint.awardPoints(
      req.userId,
      'comment_added',
      3,
      'Added a comment',
      post._id,
      'Post'
    );

    // Award points to post creator if different user
    if (!post.userId._id.equals(req.userId)) {
      await HoslaPoint.awardPoints(
        post.userId._id,
        'post_liked',
        1,
        'Someone commented on your post',
        post._id,
        'Post'
      );

      // Create notification for post owner
      await Notification.createPostCommentNotification(
        post.userId._id,
        req.userId,
        post._id,
        content
      );
    }

    const newComment = post.comments[post.comments.length - 1];

    logger.logBusinessEvent('COMMENT_ADDED', req.userId, { 
      postId: post._id,
      commentId: newComment._id,
      postOwnerId: post.userId._id 
    });

    return responseHelper.created(res, 'Comment added successfully', {
      comment: newComment,
      commentCount: post.commentCount
    });

  } catch (error) {
    logger.error('Add comment error:', error);
    return responseHelper.serverError(res, 'Failed to add comment');
  }
});

// Get comments for post
router.get('/:postId/comments', validateObjectId('postId'), validatePagination, async (req, res) => {
  try {
    const { postId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const post = await Post.findById(postId)
      .populate({
        path: 'comments.userId',
        select: 'name profilePicture'
      });

    if (!post || !post.isVisible || post.moderationStatus !== 'approved') {
      return responseHelper.notFound(res, 'Post not found');
    }

    // Sort comments by creation date (newest first) and paginate
    const comments = post.comments
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(skip, skip + limit);

    const total = post.comments.length;

    return responseHelper.paginated(res, comments, { page, limit, total });

  } catch (error) {
    logger.error('Get comments error:', error);
    return responseHelper.serverError(res, 'Failed to get comments');
  }
});

// Delete comment
router.delete('/:postId/comments/:commentId', authenticateToken, validateObjectId('postId'), async (req, res) => {
  try {
    const { postId, commentId } = req.params;

    const post = await Post.findById(postId);
    if (!post) {
      return responseHelper.notFound(res, 'Post not found');
    }

    const comment = post.comments.id(commentId);
    if (!comment) {
      return responseHelper.notFound(res, 'Comment not found');
    }

    // Check if user owns the comment or the post
    if (!comment.userId.equals(req.userId) && !post.userId.equals(req.userId)) {
      return responseHelper.forbidden(res, 'Not authorized to delete this comment');
    }

    await post.removeComment(commentId);

    logger.logBusinessEvent('COMMENT_DELETED', req.userId, { 
      postId: post._id,
      commentId 
    });

    return responseHelper.success(res, 'Comment deleted successfully');

  } catch (error) {
    logger.error('Delete comment error:', error);
    return responseHelper.serverError(res, 'Failed to delete comment');
  }
});

// Share post
router.post('/:postId/share', authenticateToken, validateObjectId('postId'), async (req, res) => {
  try {
    const { postId } = req.params;

    const post = await Post.findById(postId);
    if (!post || !post.isVisible || post.moderationStatus !== 'approved') {
      return responseHelper.notFound(res, 'Post not found');
    }

    await post.addShare(req.userId);

    // Award points to post creator
    if (!post.userId.equals(req.userId)) {
      await HoslaPoint.awardPoints(
        post.userId,
        'post_liked',
        5,
        'Someone shared your post',
        post._id,
        'Post'
      );
    }

    logger.logBusinessEvent('POST_SHARED', req.userId, { 
      postId: post._id,
      postOwnerId: post.userId 
    });

    return responseHelper.success(res, 'Post shared successfully', {
      shareCount: post.shareCount
    });

  } catch (error) {
    logger.error('Share post error:', error);
    return responseHelper.serverError(res, 'Failed to share post');
  }
});

// Search posts
router.get('/search', validatePagination, async (req, res) => {
  try {
    const { q, tags, mediaType } = req.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    if (!q || q.trim().length < 2) {
      return responseHelper.error(res, 'Search query must be at least 2 characters', 400);
    }

    let query = {
      isVisible: true,
      moderationStatus: 'approved',
      $text: { $search: q.trim() }
    };

    // Add filters
    if (tags) {
      const tagArray = Array.isArray(tags) ? tags : [tags];
      query.tags = { $in: tagArray };
    }

    if (mediaType) {
      query.mediaType = mediaType;
    }

    const posts = await Post.find(query)
      .populate('userId', 'name profilePicture')
      .sort({ score: { $meta: 'textScore' }, createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments(query);

    return responseHelper.paginated(res, posts, { page, limit, total });

  } catch (error) {
    logger.error('Search posts error:', error);
    return responseHelper.serverError(res, 'Failed to search posts');
  }
});

module.exports = router;
