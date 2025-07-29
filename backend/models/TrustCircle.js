const mongoose = require('mongoose');

const trustCircleSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  members: [{
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    addedAt: {
      type: Date,
      default: Date.now
    },
    addedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    relationship: {
      type: String,
      enum: ['family', 'friend', 'neighbor', 'caregiver', 'doctor', 'other'],
      default: 'other'
    },
    isEmergencyContact: {
      type: Boolean,
      default: true
    },
    canViewLocation: {
      type: Boolean,
      default: false
    },
    notificationPreferences: {
      emergency: { type: Boolean, default: true },
      posts: { type: Boolean, default: true },
      events: { type: Boolean, default: false }
    }
  }],
  invitations: [{
    invitedUserId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    invitedAt: {
      type: Date,
      default: Date.now
    },
    invitationMessage: {
      type: String,
      trim: true,
      maxlength: 300
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'declined', 'expired'],
      default: 'pending'
    },
    expiresAt: {
      type: Date,
      default: function() {
        return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
      }
    }
  }],
  settings: {
    autoAcceptFamily: {
      type: Boolean,
      default: false
    },
    requireApprovalForAll: {
      type: Boolean,
      default: true
    },
    maxMembers: {
      type: Number,
      default: 10,
      min: 1,
      max: 20
    },
    allowMemberInvites: {
      type: Boolean,
      default: false
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for member count
trustCircleSchema.virtual('memberCount').get(function() {
  return this.members.length;
});

// Virtual for pending invitations count
trustCircleSchema.virtual('pendingInvitationsCount').get(function() {
  return this.invitations.filter(inv => inv.status === 'pending').length;
});

// Virtual for emergency contacts count
trustCircleSchema.virtual('emergencyContactsCount').get(function() {
  return this.members.filter(member => member.isEmergencyContact).length;
});

// Method to add member
trustCircleSchema.methods.addMember = function(memberId, addedBy, relationship = 'other', isEmergencyContact = true) {
  // Check if already a member
  if (this.isMember(memberId)) {
    throw new Error('User is already a member');
  }
  
  // Check max members limit
  if (this.members.length >= this.settings.maxMembers) {
    throw new Error('Trust circle is full');
  }
  
  this.members.push({
    memberId,
    addedBy,
    relationship,
    isEmergencyContact
  });
  
  return this.save();
};

// Method to remove member
trustCircleSchema.methods.removeMember = function(memberId) {
  this.members = this.members.filter(member => !member.memberId.equals(memberId));
  return this.save();
};

// Method to check if user is member
trustCircleSchema.methods.isMember = function(userId) {
  return this.members.some(member => member.memberId.equals(userId));
};

// Method to get member
trustCircleSchema.methods.getMember = function(userId) {
  return this.members.find(member => member.memberId.equals(userId));
};

// Method to update member settings
trustCircleSchema.methods.updateMember = function(memberId, updates) {
  const member = this.getMember(memberId);
  if (!member) {
    throw new Error('Member not found');
  }
  
  Object.assign(member, updates);
  return this.save();
};

// Method to send invitation
trustCircleSchema.methods.sendInvitation = function(invitedUserId, invitationMessage = '') {
  // Check if already invited or member
  if (this.isMember(invitedUserId) || this.hasInvitation(invitedUserId)) {
    throw new Error('User is already a member or has pending invitation');
  }
  
  // Check max members limit
  if (this.members.length >= this.settings.maxMembers) {
    throw new Error('Trust circle is full');
  }
  
  this.invitations.push({
    invitedUserId,
    invitationMessage
  });
  
  return this.save();
};

// Method to check if user has pending invitation
trustCircleSchema.methods.hasInvitation = function(userId) {
  return this.invitations.some(inv => 
    inv.invitedUserId.equals(userId) && 
    inv.status === 'pending' && 
    inv.expiresAt > new Date()
  );
};

// Method to get invitation
trustCircleSchema.methods.getInvitation = function(userId) {
  return this.invitations.find(inv => 
    inv.invitedUserId.equals(userId) && 
    inv.status === 'pending' && 
    inv.expiresAt > new Date()
  );
};

// Method to accept invitation
trustCircleSchema.methods.acceptInvitation = function(userId, relationship = 'other') {
  const invitation = this.getInvitation(userId);
  if (!invitation) {
    throw new Error('No valid invitation found');
  }
  
  // Add as member
  this.addMember(userId, this.userId, relationship);
  
  // Update invitation status
  invitation.status = 'accepted';
  
  return this.save();
};

// Method to decline invitation
trustCircleSchema.methods.declineInvitation = function(userId) {
  const invitation = this.getInvitation(userId);
  if (!invitation) {
    throw new Error('No valid invitation found');
  }
  
  invitation.status = 'declined';
  return this.save();
};

// Method to get emergency contacts
trustCircleSchema.methods.getEmergencyContacts = function() {
  return this.members.filter(member => member.isEmergencyContact);
};

// Method to get members by relationship
trustCircleSchema.methods.getMembersByRelationship = function(relationship) {
  return this.members.filter(member => member.relationship === relationship);
};

// Static method to get trust circle for user
trustCircleSchema.statics.getTrustCircleForUser = function(userId) {
  return this.findOne({ userId }).populate('members.memberId', 'name profilePicture phoneNumber isActive');
};

// Static method to cleanup expired invitations
trustCircleSchema.statics.cleanupExpiredInvitations = function() {
  return this.updateMany(
    { 'invitations.expiresAt': { $lt: new Date() }, 'invitations.status': 'pending' },
    { $set: { 'invitations.$.status': 'expired' } }
  );
};

// Pre-save middleware to cleanup expired invitations
trustCircleSchema.pre('save', function(next) {
  const now = new Date();
  this.invitations.forEach(invitation => {
    if (invitation.status === 'pending' && invitation.expiresAt < now) {
      invitation.status = 'expired';
    }
  });
  next();
});

// Indexes
trustCircleSchema.index({ userId: 1 }, { unique: true });
trustCircleSchema.index({ 'members.memberId': 1 });
trustCircleSchema.index({ 'invitations.invitedUserId': 1, 'invitations.status': 1 });

module.exports = mongoose.model('TrustCircle', trustCircleSchema);
