class uber::config (
  # sideboard config file settings only below
  $sideboard_debug_enabled = false,
  $hostname = $uber::hostname,
  $socket_port = hiera('uber::socket_port'),
  $socket_host = '0.0.0.0',
  $ssl_port = hiera('uber::ssl_port'),
  $priority_plugins = 'uber,',

  # ubersystem config file settings only below
  $url_prefix = 'uber',

  $db_user = 'rams',
  $db_pass = 'rams',
  $db_name = 'rams',
  $db_host = 'localhost',
  $db_port = 5432,

  $django_debug = false,

  $event_name,
  $organization_name,
  $year,

  $show_custom_badge_input = true,
  $shirt_sales_enabled = true,
  $show_affiliates = true,
  #$group_reg_available = True,
  #$group_reg_open = True,
  $send_emails = false,
  $aws_access_key = '',
  $aws_secret_key = '',
  $stripe_secret_key = '',
  $stripe_public_key = '',
  $dev_box = false,
  $collect_exact_birthdate = false,
  $collect_full_address = false,
  #$supporter_badge_type_enabled = True,
  $prereg_open = '',
  $shifts_created = '',
  $prereg_takedown = '',
  $group_prereg_takedown = '',
  $uber_takedown = '',
  $epoch = '',
  $eschaton = '',
  #$prereg_price = 45,
  #$at_door_price = 60,
  $groups_enabled = true,
  $numbered_badges = true,
  $one_days_enabled = true,
  $at_the_con = false,
  $post_con = false,
  $max_badge_sales = 9999999,
  $hide_schedule = true,
  $hotel_req_hours = 24,
  $shift_custom_badges = true,
  $preassigned_badge_types = "'staff_badge', 'supporter_badge'",
  $printed_badge_deadline = '',

  $uber_shut_down = false,

  $dealer_reg_start = '',
  $dealer_reg_deadline = '',
  $dealer_reg_shutdown = '',
  $dealer_payment_due = '',

  $badge_enums = {
    "attendee_badge" => "Attendee",
    "supporter_badge" => "Supporter",
    "staff_badge" => "Staff",
    "guest_badge" => "Guest",
    "one_day_badge" => "One Day",
  },
  $badge_types = [
    [ "guest_badge",
      {"range_start" => 2000, "range_end" => 2999 }

    ],
    [ "staff_badge",
      {"range_start" => 1, "range_end" => 999 }
    ],
    [
      "attendee_badge",
      {"range_start" => 3000, "range_end" => 29999 }
    ],
  ],
  $badge_prices = [],
  $shirt_level = 20,
  $supporter_level = 60,
  $season_level = 160,
  $volunteer_form_visible = false,
  $consent_form_url = '',
  $code_of_conduct,
  $contact_url,
  $donations_enabled = true,
  $supporter_deadline = "2014-12-26",
  $placeholder_deadline = '2015-06-16',
  $room_deadline = '',
  $shirt_deadline = '',
  $shirt_sizes = [
    "'no shirt' = 0",
  ],
  $out_of_shirts = false,
  $initial_attendee = 50,
  $max_dealers = 20,
  $dealer_badge_price = 40,
  $default_table_price = 100,
  $table_prices = [],
  $event_timezone = "US/Eastern",
  $donation_tier = [
    "'No thanks' = 0",
    "'Ribbon' = 5",
    "'Button' = 10",
    "'Tshirt' = SHIRT_LEVEL",
    "'Supporter Package' = SUPPORTER_LEVEL",
    "'USB Drive' = 100",
    "'Season Supporter Pass for 2015' = SEASON_LEVEL",
    "'MPoint Holder' = 200",
    "'SpaceSuit' = 500",
  ],
  $extra_ribbon_types = [],
  $job_interests = [],
  $job_locations = [],
  $sandwich = [],
  $food_restriction = [],
  $shiftless_depts = undef,
  $interest_list = [],
  $event_locations = [],
  $dept_head_overrides = [
    "staff_support = 'Jack Boyd'",
    "security = 'The Dorsai Irregulars'"
  ],
  $dept_head_checklist = [],
  $volunteer_checklist = [],
  $regdesk_sig = " - Victoria Earl,\nMAGFest Registration Chair",
  $stops_sig = "Jack Boyd\nStaffing Coordinator\nMAGFest\nhttp://magfest.org",
  $marketplace_sig = " - Danielle Pomfrey,\nMAGFest Marketplace Coordinator",
  $peglegs_sig = " - Tim Macneil,\nMAGFest Panels Department",
  $guest_sig = " - Steph Prader,\nMAGFest Guest Coordinator",
  $admin_email = "Eli Courtwright <eli@courtwright.org>",
  $regdesk_email = "MAGFest Registration <regdesk@magfest.org>",
  $staff_email = "MAGFest Staffing <stops@magfest.org>",
  $marketplace_email = "MAGFest Marketplace <marketplace@magfest.org>",
  $panels_email = "MAGFest Panels <panels@magfest.org>",
  $developer_email = "Eli Courtwright <code@magfest.org>",

  $supporter_stock = undef,

  # rockage-specific stuff
  $student_discount = 0,
  $collect_interests = true,

  # magstock-specific stuff
  $noise_levels = undef,
  $shirt_colors = undef,
  $site_types = undef,
  $camping_types = undef,
  $coming_as_types = undef,
  $food_stock      = undef,
  $food_price      = undef,

  $log_to_stderr = false,
) {

  require uber::plugins

  if $ssl_port == 443 {
    $url_root = "https://${hostname}"
  } else {
    $url_root = "https://${hostname}:${ssl_port}"
  }

  # TODO: so, really, these should be eventually split out into separate classes
  # TODO: development.ini should be refactored to somehow be treated like any other plugin, instead of us
  #       special-casing uber's development.ini here.

  # sideboard's development.ini
  file { "${uber::uber_path}/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/sb-development.ini.erb'),
  }

  # uber's development.ini
  file { "${uber::uber_path}/plugins/uber/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/uber-development.ini.erb'),
  }
}
