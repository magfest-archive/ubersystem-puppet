class uber::config (
  # sideboard config file settings only below
  $sideboard_debug_enabled = false,
  $priority_plugins = "uber,",
  $hostname = $uber::hostname,
  $url_base = '%(url_root)s%(path)s',
  $socket_port = hiera('uber::socket_port'),
  $socket_host = '0.0.0.0',
  $engine_autoreload = true,
  $ssl_port = hiera('uber::ssl_port'),

  $hardcore_optimizations_enabled = false,

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

  $event_venue = '',
  $event_venue_address = '',

  $event_qr_id = '',
  $qr_code_password = '',

  $show_custom_badge_input = true,
  $shirt_sales_enabled = true,
  $show_affiliates = true,
  #$group_reg_available = True,
  #$group_reg_open = True,
  $send_emails = false,
  $send_sms = false,
  $use_checkin_barcode = true,
  $badge_promo_codes_enabled = false,
  $prereg_confirm_email_enabled = false,
  $prereg_request_hotel_info_duration = 0,
  $prereg_hotel_info_email_sender = 'Do Not Reply <noreply@magfest.org>',
  $prereg_hotel_info_email_signature = 'MAGFest',

  $api_enabled = true,
  $aws_access_key = '',
  $aws_secret_key = '',
  # Test stripe keys associated with our test stripe account
  $stripe_secret_key = 'sk_test_QHnlImUs68dQFxgTfVauz5Ue',
  $stripe_public_key = 'pk_test_q4kSJVwk6LXKv2ahxuVn7VOK',
  $dev_box = false,
  $collect_exact_birthdate = false,
  $collect_full_address = false,
  $collect_extra_donation = false,
  $kiosk_cc_enabled = false,
  $only_prepay_at_door = false,
  #$supporter_badge_type_enabled = True,
  $prereg_open = '',
  $hide_prereg_open_date = false,
  $shifts_created = '',
  $prereg_takedown = '',
  $group_prereg_takedown = '',
  $uber_takedown = '',
  $epoch = '',
  $eschaton = '',
  #$prereg_price = 45,
  #$at_door_price = 60,
  $groups_enabled = true,
  $group_discount = 10,
  $numbered_badges = true,
  $one_days_enabled = true,
  $presell_one_days = true,
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

  $badge_price_waived = '',

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
  $badge_stocks = {},
  $badge_prices = [],
  $shirt_level = 20,
  $supporter_level = 60,
  $season_level = 160,
  $volunteer_form_visible = false,
  $consent_form_url = '',
  $code_of_conduct,
  $prereg_faq_url,
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
  $shirts_per_staffer = undef,
  $staff_eligible_for_swag_shirt = undef,
  $initial_attendee = 50,
  $max_dealers = 20,
  $max_dealer_apps = 0,
  $dealer_badge_price = 40,
  $default_table_price = 100,
  $table_prices = [],
  $event_timezone = "US/Eastern",
  $donation_tier = [],
  $donation_tier_descriptions = [],
  $extra_ribbon_types = [],
  $job_interests = [],
  $job_locations = [],
  $sandwich = [],
  $food_restriction = [],
  $shiftless_depts = undef,
  $interest_list = [],
  $dealer_wares = [],
  $event_locations = [],
  $dept_head_overrides = [],
  $dept_head_checklist = [],
  $volunteer_checklist = [],
  $age_groups = [],
  $regdesk_sig = " - Victoria Earl,\nMAGFest Registration Chair",
  $stops_sig = "Brent Smart\nStaff Operations\nMAGFest\nhttp://magfest.org",
  $marketplace_sig = " - Danielle Pomfrey,\nMAGFest Marketplace Coordinator",
  $peglegs_sig = " - Tim Macneil,\nMAGFest Panels Department",
  $guest_sig = " - Steph Prader,\nMAGFest Guest Coordinator",
  $admin_email = "MAGFest Sys Admins <sysadmin@magfest.org>",
  $regdesk_email = "MAGFest Registration <regdesk@magfest.org>",
  $staff_email = "MAGFest Staffing <stops@magfest.org>",
  $marketplace_email = "MAGFest Marketplace <marketplace@magfest.org>",
  $panels_email = "MAGFest Panels <panels@magfest.org>",
  $developer_email = "MAGFest Software <code@magfest.org>",

  $supporter_stock = undef,

  # rockage-specific stuff
  $student_discount = 0,
  $collect_interests = true,

  $log_to_stdout = true,
  $log_to_syslog = false,
  $log_force_multiline_indent = false,

  # barcode
  $barcode_key = "",
  $barcode_salt = 0,
  $barcode_event_id = 0,
  
  # hotel
  $hotel_req_hours = undef,
  
  # mivs
  $mivs_round_one_deadline = undef,
  $mivs_video_response_expected = undef,
  $mivs_round_two_start = undef,
  $mivs_round_two_deadline = undef,
  $mivs_judging_deadline = undef,
  $mivs_round_two_complete = undef,
  $mivs_confirm_deadline = undef,
  $mivs_submission_grace_period = undef,
  $mivs_start_year = undef,
  
  # magfest
  $treasury_dept_checklist_form_url = '',
  $techops_dept_checklist_form_url = '',
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
  
  # plugins that have been merged into uber
  file {'remove_barcode':
    ensure  => absent,
    path    => "${uber::plugins_dir}/barcode",
    recurse => true,
    purge   => true,
    force   => true,
  }

  file {'remove_reports':
    ensure  => absent,
    path    => "${uber::plugins_dir}/reports",
    recurse => true,
    purge   => true,
    force   => true,
  }

  file {'remove_uber_analytics':
    ensure  => absent,
    path    => "${uber::plugins_dir}/uber_analytics",
    recurse => true,
    purge   => true,
    force   => true,
  }

  file {'remove_hotel':
    ensure  => absent,
    path    => "${uber::plugins_dir}/hotel",
    recurse => true,
    purge   => true,
    force   => true,
  }

  file {'remove_attendee_tournaments':
    ensure  => absent,
    path    => "${uber::plugins_dir}/attendee_tournaments",
    recurse => true,
    purge   => true,
    force   => true,
  }

  # file {'remove_mivs':
  #   ensure  => absent,
  #   path    => "${uber::plugins_dir}/mivs",
  #   recurse => true,
  #   purge   => true,
  #   force   => true,
  # }

  # file {'remove_mits':
  #   ensure  => absent,
  #   path    => "${uber::plugins_dir}/mits",
  #   recurse => true,
  #   purge   => true,
  #   force   => true,
  # }

  file {'remove_magfest':
    ensure  => absent,
    path    => "${uber::plugins_dir}/magfest",
    recurse => true,
    purge   => true,
    force   => true,
  }
}
