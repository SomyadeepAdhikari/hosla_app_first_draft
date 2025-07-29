const moment = require('moment');

// Date formatting utilities for Indian locale and senior-friendly formats

// Format date for display (senior-friendly)
const formatDisplayDate = (date, includeTime = false) => {
  if (!date) return '';
  
  const momentDate = moment(date);
  
  if (includeTime) {
    return momentDate.format('DD MMM YYYY, hh:mm A');
  }
  
  return momentDate.format('DD MMM YYYY');
};

// Format relative time (e.g., "2 hours ago")
const formatRelativeTime = (date) => {
  if (!date) return '';
  
  const momentDate = moment(date);
  const now = moment();
  
  const diffMinutes = now.diff(momentDate, 'minutes');
  const diffHours = now.diff(momentDate, 'hours');
  const diffDays = now.diff(momentDate, 'days');
  
  if (diffMinutes < 1) {
    return 'अभी-अभी'; // Just now in Hindi
  } else if (diffMinutes < 60) {
    return `${diffMinutes} मिनट पहले`; // minutes ago in Hindi
  } else if (diffHours < 24) {
    return `${diffHours} घंटे पहले`; // hours ago in Hindi
  } else if (diffDays < 7) {
    return `${diffDays} दिन पहले`; // days ago in Hindi
  } else {
    return formatDisplayDate(date);
  }
};

// Format time only (12-hour format)
const formatTime = (date) => {
  if (!date) return '';
  return moment(date).format('hh:mm A');
};

// Format date for Hindi locale
const formatHindiDate = (date) => {
  if (!date) return '';
  
  const momentDate = moment(date);
  const day = momentDate.format('DD');
  const year = momentDate.format('YYYY');
  
  const hindiMonths = {
    '01': 'जनवरी',
    '02': 'फरवरी', 
    '03': 'मार्च',
    '04': 'अप्रैल',
    '05': 'मई',
    '06': 'जून',
    '07': 'जुलाई',
    '08': 'अगस्त',
    '09': 'सितंबर',
    '10': 'अक्टूबर',
    '11': 'नवंबर',
    '12': 'दिसंबर'
  };
  
  const month = hindiMonths[momentDate.format('MM')];
  return `${day} ${month} ${year}`;
};

// Check if date is today
const isToday = (date) => {
  if (!date) return false;
  return moment(date).isSame(moment(), 'day');
};

// Check if date is yesterday
const isYesterday = (date) => {
  if (!date) return false;
  return moment(date).isSame(moment().subtract(1, 'day'), 'day');
};

// Check if date is this week
const isThisWeek = (date) => {
  if (!date) return false;
  return moment(date).isSame(moment(), 'week');
};

// Get age from date of birth
const getAge = (dateOfBirth) => {
  if (!dateOfBirth) return null;
  return moment().diff(moment(dateOfBirth), 'years');
};

// Get start and end of day
const getStartOfDay = (date = new Date()) => {
  return moment(date).startOf('day').toDate();
};

const getEndOfDay = (date = new Date()) => {
  return moment(date).endOf('day').toDate();
};

// Get start and end of week
const getStartOfWeek = (date = new Date()) => {
  return moment(date).startOf('week').toDate();
};

const getEndOfWeek = (date = new Date()) => {
  return moment(date).endOf('week').toDate();
};

// Get start and end of month
const getStartOfMonth = (date = new Date()) => {
  return moment(date).startOf('month').toDate();
};

const getEndOfMonth = (date = new Date()) => {
  return moment(date).endOf('month').toDate();
};

// Add time to date
const addTime = (date, amount, unit) => {
  return moment(date).add(amount, unit).toDate();
};

// Subtract time from date
const subtractTime = (date, amount, unit) => {
  return moment(date).subtract(amount, unit).toDate();
};

// Check if date is in the past
const isPast = (date) => {
  if (!date) return false;
  return moment(date).isBefore(moment());
};

// Check if date is in the future
const isFuture = (date) => {
  if (!date) return false;
  return moment(date).isAfter(moment());
};

// Format duration (e.g., for event duration)
const formatDuration = (startDate, endDate) => {
  if (!startDate || !endDate) return '';
  
  const start = moment(startDate);
  const end = moment(endDate);
  const duration = moment.duration(end.diff(start));
  
  const days = duration.days();
  const hours = duration.hours();
  const minutes = duration.minutes();
  
  if (days > 0) {
    return `${days} दिन ${hours} घंटे`;
  } else if (hours > 0) {
    return `${hours} घंटे ${minutes} मिनट`;
  } else {
    return `${minutes} मिनट`;
  }
};

// Get time until event (for reminders)
const getTimeUntilEvent = (eventDate) => {
  if (!eventDate) return '';
  
  const now = moment();
  const event = moment(eventDate);
  
  if (event.isBefore(now)) {
    return 'Event has passed';
  }
  
  const duration = moment.duration(event.diff(now));
  const days = duration.days();
  const hours = duration.hours();
  const minutes = duration.minutes();
  
  if (days > 0) {
    return `${days} दिन ${hours} घंटे बाकी`;
  } else if (hours > 0) {
    return `${hours} घंटे ${minutes} मिनट बाकी`;
  } else {
    return `${minutes} मिनट बाकी`;
  }
};

// Convert to Indian Standard Time
const toIST = (date) => {
  return moment(date).utcOffset('+05:30');
};

// Format for database storage (ISO string)
const toISOString = (date) => {
  if (!date) return null;
  return moment(date).toISOString();
};

// Parse date from various formats
const parseDate = (dateString) => {
  return moment(dateString).toDate();
};

// Validate date
const isValidDate = (date) => {
  return moment(date).isValid();
};

// Get calendar week info for seniors
const getWeekInfo = (date = new Date()) => {
  const momentDate = moment(date);
  return {
    weekNumber: momentDate.week(),
    startOfWeek: momentDate.clone().startOf('week').format('DD MMM'),
    endOfWeek: momentDate.clone().endOf('week').format('DD MMM'),
    year: momentDate.year()
  };
};

// Format for event scheduling (user-friendly)
const formatEventTime = (startDate, endDate) => {
  if (!startDate) return '';
  
  const start = moment(startDate);
  const end = endDate ? moment(endDate) : null;
  
  if (isToday(startDate)) {
    if (end && end.isSame(start, 'day')) {
      return `आज ${start.format('hh:mm A')} से ${end.format('hh:mm A')} तक`;
    }
    return `आज ${start.format('hh:mm A')} बजे`;
  } else if (isYesterday(startDate)) {
    return `कल ${start.format('hh:mm A')} बजे`;
  } else {
    if (end && end.isSame(start, 'day')) {
      return `${formatDisplayDate(startDate)} ${start.format('hh:mm A')} से ${end.format('hh:mm A')} तक`;
    }
    return `${formatDisplayDate(startDate)} ${start.format('hh:mm A')} बजे`;
  }
};

module.exports = {
  formatDisplayDate,
  formatRelativeTime,
  formatTime,
  formatHindiDate,
  isToday,
  isYesterday,
  isThisWeek,
  getAge,
  getStartOfDay,
  getEndOfDay,
  getStartOfWeek,
  getEndOfWeek,
  getStartOfMonth,
  getEndOfMonth,
  addTime,
  subtractTime,
  isPast,
  isFuture,
  formatDuration,
  getTimeUntilEvent,
  toIST,
  toISOString,
  parseDate,
  isValidDate,
  getWeekInfo,
  formatEventTime
};
