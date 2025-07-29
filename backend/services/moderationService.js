const User = require('../models/User');
const Post = require('../models/Post');
const logger = require('../utils/logger');

class ModerationService {
  constructor() {
    // Inappropriate content keywords in Hindi and English
    this.inappropriateKeywords = [
      // Hindi abusive words
      'बकवास', 'गंदा', 'बुरा', 'नफरत',
      // English abusive words (basic list)
      'hate', 'stupid', 'idiot', 'fool', 'bad',
      // Add more as needed
    ];

    // Spam indicators
    this.spamIndicators = [
      'click here', 'free money', 'win prize', 'urgent',
      'यहाँ क्लिक करें', 'मुफ्त पैसा', 'पुरस्कार जीतें', 'तुरंत'
    ];
  }

  // Check content for inappropriate material
  moderateContent(content) {
    if (!content || typeof content !== 'string') {
      return { approved: true, reason: null };
    }

    const lowerContent = content.toLowerCase();

    // Check for inappropriate keywords
    for (const keyword of this.inappropriateKeywords) {
      if (lowerContent.includes(keyword.toLowerCase())) {
        return {
          approved: false,
          reason: 'Inappropriate content detected',
          keyword: keyword,
          severity: 'medium'
        };
      }
    }

    // Check for spam indicators
    for (const indicator of this.spamIndicators) {
      if (lowerContent.includes(indicator.toLowerCase())) {
        return {
          approved: false,
          reason: 'Potential spam content detected',
          keyword: indicator,
          severity: 'low'
        };
      }
    }

    // Check content length (too short might be spam)
    if (content.trim().length < 3) {
      return {
        approved: false,
        reason: 'Content too short',
        severity: 'low'
      };
    }

    // Check for excessive caps (shouting)
    const capsPercentage = (content.match(/[A-Z]/g) || []).length / content.length;
    if (capsPercentage > 0.7 && content.length > 10) {
      return {
        approved: false,
        reason: 'Excessive capitalization',
        severity: 'low'
      };
    }

    // Check for repeated characters (spam indication)
    if (/(.)\1{4,}/.test(content)) {
      return {
        approved: false,
        reason: 'Repeated characters detected',
        severity: 'low'
      };
    }

    return { approved: true, reason: null };
  }

  // Moderate user profile information
  moderateProfile(profileData) {
    const results = [];

    if (profileData.name) {
      const nameCheck = this.moderateContent(profileData.name);
      if (!nameCheck.approved) {
        results.push({
          field: 'name',
          ...nameCheck
        });
      }
    }

    if (profileData.bio) {
      const bioCheck = this.moderateContent(profileData.bio);
      if (!bioCheck.approved) {
        results.push({
          field: 'bio',
          ...bioCheck
        });
      }
    }

    return {
      approved: results.length === 0,
      issues: results
    };
  }

  // Moderate post content
  moderatePost(postData) {
    const results = [];

    if (postData.content) {
      const contentCheck = this.moderateContent(postData.content);
      if (!contentCheck.approved) {
        results.push({
          field: 'content',
          ...contentCheck
        });
      }
    }

    if (postData.title) {
      const titleCheck = this.moderateContent(postData.title);
      if (!titleCheck.approved) {
        results.push({
          field: 'title',
          ...titleCheck
        });
      }
    }

    return {
      approved: results.length === 0,
      issues: results
    };
  }

  // Check user behavior patterns
  async checkUserBehavior(userId) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        return { flagged: false, reason: 'User not found' };
      }

      // Check if user was recently created (potential spam account)
      const accountAge = Date.now() - new Date(user.createdAt).getTime();
      const isNewAccount = accountAge < 24 * 60 * 60 * 1000; // Less than 24 hours

      // Get user's recent posts
      const recentPosts = await Post.find({
        userId,
        createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
      });

      // Check for spam posting behavior
      const postCount = recentPosts.length;
      const isSpamming = postCount > 10; // More than 10 posts in 24 hours

      // Check for repeated content
      const uniqueContent = new Set(recentPosts.map(post => post.content?.toLowerCase()));
      const hasRepeatedContent = uniqueContent.size < postCount * 0.5; // Less than 50% unique content

      const flags = [];

      if (isNewAccount && isSpamming) {
        flags.push('New account with high posting frequency');
      }

      if (hasRepeatedContent && postCount > 3) {
        flags.push('Posting repeated content');
      }

      if (user.reportedCount && user.reportedCount > 5) {
        flags.push('Multiple user reports');
      }

      return {
        flagged: flags.length > 0,
        flags,
        metadata: {
          accountAge: Math.floor(accountAge / (1000 * 60 * 60)), // in hours
          recentPostCount: postCount,
          uniqueContentRatio: uniqueContent.size / (postCount || 1),
          reportedCount: user.reportedCount || 0
        }
      };

    } catch (error) {
      logger.error('Check user behavior error:', error);
      return { flagged: false, error: error.message };
    }
  }

  // Report content
  async reportContent(contentId, contentType, reporterId, reason) {
    try {
      let content;
      
      if (contentType === 'post') {
        content = await Post.findById(contentId);
      } else if (contentType === 'user') {
        content = await User.findById(contentId);
      }

      if (!content) {
        return { success: false, message: 'Content not found' };
      }

      // Initialize reports array if not exists
      if (!content.reports) {
        content.reports = [];
      }

      // Check if user already reported this content
      const existingReport = content.reports.find(
        report => report.reporterId.equals(reporterId)
      );

      if (existingReport) {
        return { success: false, message: 'Already reported by this user' };
      }

      // Add new report
      content.reports.push({
        reporterId,
        reason,
        reportedAt: new Date()
      });

      // Update reported count
      content.reportedCount = (content.reportedCount || 0) + 1;

      await content.save();

      // Auto-moderate if too many reports
      if (content.reportedCount >= 5) {
        if (contentType === 'post') {
          content.isModerated = true;
          content.moderationReason = 'Multiple user reports';
          await content.save();
        } else if (contentType === 'user') {
          content.isRestricted = true;
          content.restrictionReason = 'Multiple user reports';
          await content.save();
        }
      }

      logger.info(`Content reported: ${contentType} ${contentId} by user ${reporterId}`);

      return { 
        success: true, 
        message: 'Content reported successfully',
        reportCount: content.reportedCount
      };

    } catch (error) {
      logger.error('Report content error:', error);
      return { success: false, error: error.message };
    }
  }

  // Get moderation statistics
  async getModerationStats() {
    try {
      const [
        totalPosts,
        moderatedPosts,
        totalUsers,
        restrictedUsers,
        recentReports
      ] = await Promise.all([
        Post.countDocuments(),
        Post.countDocuments({ isModerated: true }),
        User.countDocuments(),
        User.countDocuments({ isRestricted: true }),
        Post.aggregate([
          { $unwind: '$reports' },
          { 
            $match: { 
              'reports.reportedAt': { 
                $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) 
              } 
            } 
          },
          { $count: 'count' }
        ])
      ]);

      return {
        posts: {
          total: totalPosts,
          moderated: moderatedPosts,
          moderationRate: totalPosts > 0 ? (moderatedPosts / totalPosts * 100).toFixed(2) : 0
        },
        users: {
          total: totalUsers,
          restricted: restrictedUsers,
          restrictionRate: totalUsers > 0 ? (restrictedUsers / totalUsers * 100).toFixed(2) : 0
        },
        reports: {
          lastWeek: recentReports[0]?.count || 0
        }
      };

    } catch (error) {
      logger.error('Get moderation stats error:', error);
      throw error;
    }
  }
}

module.exports = new ModerationService();
