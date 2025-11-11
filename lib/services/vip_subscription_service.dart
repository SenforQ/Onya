import '../models/vip_subscription.dart';

class VipSubscriptionService {
  static List<VipSubscription> getSubscriptions() {
    return const <VipSubscription>[
      VipSubscription(
        id: 'weekly',
        productId: 'Subsweete3_29',
        price: 12.99,
        currency: '\$',
        subtitle: 'Weekly Subscription',
        isMostPopular: false,
      ),
      VipSubscription(
        id: 'monthly',
        productId: 'Subsweete3_29',
        price: 49.99,
        currency: '\$',
        subtitle: 'Monthly Subscription',
        isMostPopular: true,
      ),
    ];
  }

  static List<VipPrivilege> getPrivileges() {
    return const <VipPrivilege>[
      VipPrivilege(title: 'Unlimited access to all music content'),
      VipPrivilege(title: 'Ad-free experience'),
      VipPrivilege(title: 'Priority customer support'),
      VipPrivilege(title: 'Exclusive VIP-only features'),
      VipPrivilege(title: 'Early access to new releases'),
    ];
  }
}

