import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _showEditProfilePicture(context),
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              iconSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Name and Phone
                    Text(
                      'Sunita Sharma', // Sample name
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+91 98765 43210', // Sample phone
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Edit Profile Button
                    ElevatedButton.icon(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Trust Circle Groups Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.family_restroom,
                          size: 28,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'My Trust Circles',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Groups List
                    _buildGroupTile(
                      context,
                      'Family Group',
                      '4 members',
                      Icons.family_restroom,
                      Colors.blue,
                      ['Ram Sharma', 'Sunita Devi', 'Ajay Kumar', 'Priya Sharma'],
                    ),
                    const SizedBox(height: 12),
                    _buildGroupTile(
                      context,
                      'Medical Team',
                      '2 members',
                      Icons.medical_services,
                      Colors.red,
                      ['Dr. Rajesh Verma', 'Nurse Rita'],
                    ),
                    const SizedBox(height: 12),
                    _buildGroupTile(
                      context,
                      'Neighbors',
                      '3 members',
                      Icons.home,
                      Colors.green,
                      ['Mrs. Gupta', 'Mr. Singh', 'Ravi Uncle'],
                    ),
                    const SizedBox(height: 12),
                    _buildGroupTile(
                      context,
                      'Yoga Friends',
                      '5 members',
                      Icons.self_improvement,
                      Colors.purple,
                      ['Meera Aunty', 'Kamla Devi', 'Sushma Ji', 'Radha Mam', 'Geeta Mam'],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Personal Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 28,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoRow(Icons.cake, 'Age', '68 years'),
                    _buildInfoRow(Icons.location_on, 'Address', 'Sector 15, Delhi'),
                    _buildInfoRow(Icons.bloodtype, 'Blood Group', 'B+'),
                    _buildInfoRow(Icons.medical_services, 'Medical Conditions', 'Diabetes, High BP'),
                    _buildInfoRow(Icons.medication, 'Current Medications', '3 medicines'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Emergency Contacts Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emergency,
                          size: 28,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Emergency Contacts',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildEmergencyContact(
                      context,
                      'Primary Contact',
                      'Ram Sharma (Son)',
                      '+91 98765 43210',
                      Icons.person,
                    ),
                    const Divider(height: 24),
                    _buildEmergencyContact(
                      context,
                      'Secondary Contact',
                      'Dr. Rajesh Verma',
                      '+91 87654 32109',
                      Icons.medical_services,
                    ),
                    const Divider(height: 24),
                    _buildEmergencyContact(
                      context,
                      'Neighbor Contact',
                      'Mrs. Gupta',
                      '+91 76543 21098',
                      Icons.home,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // App Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 28,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Activity Summary',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            '15',
                            'Posts Shared',
                            Icons.post_add,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            '42',
                            'Messages Sent',
                            Icons.message,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            '8',
                            'Events Attended',
                            Icons.event,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            '28',
                            'Days Active',
                            Icons.calendar_today,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTile(
    BuildContext context,
    String groupName,
    String memberCount,
    IconData icon,
    Color color,
    List<String> members,
  ) {
    return InkWell(
      onTap: () => _showGroupDetails(context, groupName, members),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memberCount,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(
    BuildContext context,
    String type,
    String name,
    String phone,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _makeCall(context, name, phone),
          icon: const Icon(Icons.call, color: Colors.green),
          tooltip: 'Call $name',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String number,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showGroupDetails(BuildContext context, String groupName, List<String> members) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(groupName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members (${members.length}):',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...members.map((member) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(member, style: const TextStyle(fontSize: 16)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $groupName chat...')),
              );
            },
            child: const Text('Open Chat'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: 'Sunita Sharma');
    final phoneController = TextEditingController(text: '+91 98765 43210');
    final addressController = TextEditingController(text: 'Sector 15, Delhi');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditProfilePicture(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: const Text('Choose how you want to update your profile picture:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera feature coming soon!')),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gallery feature coming soon!')),
              );
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ],
      ),
    );
  }

  void _makeCall(BuildContext context, String name, String phone) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.call, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Call Contact'),
          ],
        ),
        content: Text('Call $name at $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $name...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Call', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
