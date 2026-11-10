extends DMDialogueProcessor

const BEATS_PER_MEASURE := 4.0;

const BEATS_PER_MINUTE := 160.0;

## A value measuring beats-per-minute as a raw time value in seconds.
const BASE_PAUSE := 60.0 / BEATS_PER_MINUTE * BEATS_PER_MEASURE;

## A measure of the relative typing speed. A value of 1.0 represents the
## default speed as set in Dialogue Manager's project settings.
const BASE_SPEED := 1.0;


# [TODO] [speed] does not affect the passage of [wait]
#     [p1] => [do relative_wait(1.0)]
# [TODO] [wait] or [wait="text_advance"].


const replacements := [
  # Pauses as expressed in musical notation in 4/4 time.
  # p1 is a whole note. p4 is a quarter. pb is a breve. And pl is a longa.
  ["[pl]",  "[wait=%s]" % (BASE_PAUSE)],
  ["[pl.]", "[wait=%s]" % (BASE_PAUSE * 4.0 * 1.5)],
  ["[pb]",  "[wait=%s]" % (BASE_PAUSE * 2.0)],
  ["[pb.]", "[wait=%s]" % (BASE_PAUSE * 2.0 * 1.5)],
  ["[p1]",  "[wait=%s]" % (BASE_PAUSE)],
  ["[p1.]", "[wait=%s]" % (BASE_PAUSE * 1.5)],
  ["[p2]",  "[wait=%s]" % (BASE_PAUSE / 2.0)],
  ["[p2.]", "[wait=%s]" % (BASE_PAUSE / 2.0 * 1.5)],
  ["[p3]",  "[wait=%s]" % (BASE_PAUSE / 3.0)],
  ["[p3.]", "[wait=%s]" % (BASE_PAUSE / 3.0 * 1.5)],
  ["[p4]",  "[wait=%s]" % (BASE_PAUSE / 4.0)],
  ["[p4.]", "[wait=%s]" % (BASE_PAUSE / 4.0 * 1.5)],
  ["[p5]",  "[wait=%s]" % (BASE_PAUSE / 5.0)],
  ["[p5.]", "[wait=%s]" % (BASE_PAUSE / 5.0 * 1.5)],
  ["[p6]",  "[wait=%s]" % (BASE_PAUSE / 6.0)],
  ["[p6.]", "[wait=%s]" % (BASE_PAUSE / 6.0 * 1.5)],
  ["[p7]",  "[wait=%s]" % (BASE_PAUSE / 7.0)],
  ["[p7.]", "[wait=%s]" % (BASE_PAUSE / 7.0 * 1.5)],
  ["[p8]",  "[wait=%s]" % (BASE_PAUSE / 8.0)],
  ["[p8.]", "[wait=%s]" % (BASE_PAUSE / 8.0 * 1.5)],
  ["[p12]",  "[wait=%s]" % (BASE_PAUSE / 12.0)],
  ["[p12.]", "[wait=%s]" % (BASE_PAUSE / 12.0 * 1.5)],
  ["[p16]",  "[wait=%s]" % (BASE_PAUSE / 16.0)],
  ["[p16.]", "[wait=%s]" % (BASE_PAUSE / 16.0 * 1.5)],

  # Text speed keywords.
  ["[instant]", "[speed=%s]" % -1.0],
  ["[hyper]",  "[speed=%s]" % (BASE_SPEED * 2.5)],
  ["[fast]",   "[speed=%s]" % (BASE_SPEED * 1.5)],
  ["[steady]", "[speed=%s]" % (BASE_SPEED)],
  ["[slow]",   "[speed=%s]" % (BASE_SPEED * 0.66)],
  ["[sedate]", "[speed=%s]" % (BASE_SPEED * 0.34)],
]


func _preprocess_line(raw_line: String) -> String:
  var new_string := raw_line;

  for replacement in replacements:
    new_string = new_string.replace(replacement[0], replacement[1]);

  return new_string;
