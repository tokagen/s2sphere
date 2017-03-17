defmodule S2Sphere.CellId do
  defstruct id: nil
  alias S2Sphere.{
    CellId,
    LatLng,
    Point,
    Utilities
  }
  use Bitwise

  @linear_projection 0
  @tan_projection 1
  @quadratic_projection 2

  @projection @quadratic_projection

  @face_bits 3
  @num_faces 6

  @max_level 30
  @pos_bits (2 * @max_level + 1)
  @max_size 1 <<< @max_level

  @wrap_offset @num_faces <<< @pos_bits

  @swap_mask 0x01
  @invert_mask 0x02
  @lookup_bits 4
  @lookup_pos [0, 1, 682, 683, 14, 4, 685, 679, 17, 58, 688, 667, 20, 61, 702, 663, 234, 64, 705, 619, 237, 78, 708, 615, 240, 81, 762, 603, 254, 84, 765, 599, 257, 938, 768, 427, 260, 941, 782, 423, 314, 944, 785, 411, 317, 958, 788, 407, 320, 961, 1002, 363, 334, 964, 1005, 359, 337, 1018, 1008, 347, 340, 1021, 1022, 343, 5, 15, 678, 684, 9, 8, 675, 674, 31, 54, 693, 668, 24, 51, 697, 658, 230, 69, 719, 620, 227, 73, 712, 610, 245, 95, 758, 604, 249, 88, 755, 594, 271, 934, 773, 428, 264, 931, 777, 418, 310, 949, 799, 412, 307, 953, 792, 402, 325, 975, 998, 364, 329, 968, 995, 354, 351, 1014, 1013, 348, 344, 1011, 1017, 338, 59, 16, 666, 689, 55, 30, 669, 692, 33, 32, 651, 650, 36, 46, 647, 653, 218, 123, 720, 625, 221, 119, 734, 628, 203, 97, 736, 586, 199, 100, 750, 589, 272, 922, 827, 433, 286, 925, 823, 436, 288, 907, 801, 394, 302, 903, 804, 397, 379, 976, 986, 369, 375, 990, 989, 372, 353, 992, 971, 330, 356, 1006, 967, 333, 60, 21, 662, 703, 50, 25, 659, 696, 47, 37, 652, 646, 40, 41, 642, 643, 214, 124, 725, 639, 211, 114, 729, 632, 204, 111, 741, 582, 194, 104, 745, 579, 277, 918, 828, 447, 281, 915, 818, 440, 293, 908, 815, 390, 297, 898, 808, 387, 380, 981, 982, 383, 370, 985, 979, 376, 367, 997, 972, 326, 360, 1001, 962, 323, 65, 235, 618, 704, 68, 231, 621, 718, 122, 219, 624, 721, 125, 215, 638, 724, 129, 128, 555, 554, 132, 142, 551, 557, 186, 145, 539, 560, 189, 148, 535, 574, 491, 874, 833, 448, 487, 877, 836, 462, 475, 880, 890, 465, 471, 894, 893, 468, 384, 811, 897, 298, 398, 807, 900, 301, 401, 795, 954, 304, 404, 791, 957, 318, 79, 236, 614, 709, 72, 226, 611, 713, 118, 220, 629, 735, 115, 210, 633, 728, 143, 133, 556, 550, 136, 137, 546, 547, 182, 159, 540, 565, 179, 152, 530, 569, 492, 870, 847, 453, 482, 867, 840, 457, 476, 885, 886, 479, 466, 889, 883, 472, 389, 812, 911, 294, 393, 802, 904, 291, 415, 796, 950, 309, 408, 786, 947, 313, 80, 241, 602, 763, 94, 244, 605, 759, 96, 202, 587, 737, 110, 205, 583, 740, 144, 187, 561, 538, 158, 183, 564, 541, 160, 161, 522, 523, 174, 164, 525, 519, 497, 858, 848, 507, 500, 861, 862, 503, 458, 843, 864, 481, 461, 839, 878, 484, 443, 817, 912, 282, 439, 820, 926, 285, 417, 778, 928, 267, 420, 781, 942, 263, 85, 255, 598, 764, 89, 248, 595, 754, 101, 198, 588, 751, 105, 195, 578, 744, 149, 188, 575, 534, 153, 178, 568, 531, 165, 175, 518, 524, 169, 168, 515, 514, 511, 854, 853, 508, 504, 851, 857, 498, 454, 844, 869, 495, 451, 834, 873, 488, 444, 831, 917, 278, 434, 824, 921, 275, 431, 774, 933, 268, 424, 771, 937, 258, 939, 256, 426, 769, 935, 270, 429, 772, 923, 273, 432, 826, 919, 276, 446, 829, 875, 490, 449, 832, 871, 493, 452, 846, 859, 496, 506, 849, 855, 510, 509, 852, 513, 512, 171, 170, 516, 526, 167, 173, 570, 529, 155, 176, 573, 532, 151, 190, 576, 746, 107, 193, 590, 749, 103, 196, 593, 752, 91, 250, 596, 766, 87, 253, 940, 261, 422, 783, 930, 265, 419, 776, 924, 287, 437, 822, 914, 280, 441, 819, 876, 486, 463, 837, 866, 483, 456, 841, 860, 501, 502, 863, 850, 505, 499, 856, 527, 517, 172, 166, 520, 521, 162, 163, 566, 543, 156, 181, 563, 536, 146, 185, 581, 742, 108, 207, 585, 739, 98, 200, 607, 757, 92, 246, 600, 761, 82, 243, 945, 315, 410, 784, 948, 311, 413, 798, 906, 289, 395, 800, 909, 292, 391, 814, 881, 474, 464, 891, 884, 477, 478, 887, 842, 459, 480, 865, 845, 455, 494, 868, 528, 571, 177, 154, 542, 567, 180, 157, 544, 545, 138, 139, 558, 548, 141, 135, 635, 730, 113, 208, 631, 733, 116, 222, 609, 715, 74, 224, 612, 711, 77, 238, 959, 316, 406, 789, 952, 306, 403, 793, 902, 303, 396, 805, 899, 296, 386, 809, 895, 470, 469, 892, 888, 467, 473, 882, 838, 460, 485, 879, 835, 450, 489, 872, 533, 572, 191, 150, 537, 562, 184, 147, 549, 559, 134, 140, 553, 552, 131, 130, 636, 726, 127, 213, 626, 723, 120, 217, 623, 716, 70, 229, 616, 706, 67, 233, 960, 321, 362, 1003, 974, 324, 365, 999, 977, 378, 368, 987, 980, 381, 382, 983, 810, 385, 299, 896, 813, 388, 295, 910, 816, 442, 283, 913, 830, 445, 279, 916, 747, 577, 192, 106, 743, 580, 206, 109, 731, 634, 209, 112, 727, 637, 212, 126, 640, 641, 42, 43, 654, 644, 45, 39, 657, 698, 48, 27, 660, 701, 62, 23, 965, 335, 358, 1004, 969, 328, 355, 994, 991, 374, 373, 988, 984, 371, 377, 978, 806, 399, 300, 901, 803, 392, 290, 905, 821, 438, 284, 927, 825, 435, 274, 920, 748, 591, 197, 102, 738, 584, 201, 99, 732, 630, 223, 117, 722, 627, 216, 121, 645, 655, 38, 44, 649, 648, 35, 34, 671, 694, 53, 28, 664, 691, 57, 18, 1019, 336, 346, 1009, 1015, 350, 349, 1012, 993, 352, 331, 970, 996, 366, 327, 973, 794, 400, 305, 955, 797, 414, 308, 951, 779, 416, 266, 929, 775, 430, 269, 932, 753, 592, 251, 90, 756, 606, 247, 93, 714, 608, 225, 75, 717, 622, 228, 71, 699, 656, 26, 49, 695, 670, 29, 52, 673, 672, 11, 10, 676, 686, 7, 13, 1020, 341, 342, 1023, 1010, 345, 339, 1016, 1007, 357, 332, 966, 1000, 361, 322, 963, 790, 405, 319, 956, 787, 409, 312, 946, 780, 421, 262, 943, 770, 425, 259, 936, 767, 597, 252, 86, 760, 601, 242, 83, 710, 613, 239, 76, 707, 617, 232, 66, 700, 661, 22, 63, 690, 665, 19, 56, 687, 677, 12, 6, 680, 681, 2, 3]
  @lookup_ij [0, 1, 1022, 1023, 65, 4, 959, 1018, 69, 68, 955, 954, 6, 67, 1016, 957, 9, 128, 1015, 894, 12, 193, 1010, 831, 76, 197, 946, 827, 75, 134, 949, 888, 137, 136, 887, 886, 140, 201, 882, 823, 204, 205, 818, 819, 203, 142, 821, 880, 198, 79, 824, 945, 135, 74, 889, 948, 131, 10, 893, 1012, 192, 13, 830, 1011, 257, 16, 767, 1006, 260, 81, 762, 943, 324, 85, 698, 939, 323, 22, 701, 1000, 384, 25, 638, 999, 449, 28, 575, 994, 453, 92, 571, 930, 390, 91, 632, 933, 392, 153, 630, 871, 457, 156, 567, 866, 461, 220, 563, 802, 398, 219, 624, 805, 335, 214, 689, 808, 330, 151, 692, 873, 266, 147, 756, 877, 269, 208, 755, 814, 273, 272, 751, 750, 276, 337, 746, 687, 340, 341, 682, 683, 339, 278, 685, 744, 400, 281, 622, 743, 465, 284, 559, 738, 469, 348, 555, 674, 406, 347, 616, 677, 408, 409, 614, 615, 473, 412, 551, 610, 477, 476, 547, 546, 414, 475, 608, 549, 351, 470, 673, 552, 346, 407, 676, 617, 282, 403, 740, 621, 285, 464, 739, 558, 222, 463, 800, 561, 159, 458, 865, 564, 155, 394, 869, 628, 216, 397, 806, 627, 215, 334, 809, 688, 210, 271, 812, 753, 146, 267, 876, 757, 149, 328, 875, 694, 87, 326, 937, 696, 82, 263, 940, 761, 18, 259, 1004, 765, 21, 320, 1003, 702, 24, 385, 998, 639, 89, 388, 935, 634, 93, 452, 931, 570, 30, 451, 992, 573, 33, 512, 991, 510, 36, 577, 986, 447, 100, 581, 922, 443, 99, 518, 925, 504, 160, 521, 862, 503, 225, 524, 799, 498, 229, 588, 795, 434, 166, 587, 856, 437, 168, 649, 854, 375, 233, 652, 791, 370, 237, 716, 787, 306, 174, 715, 848, 309, 111, 710, 913, 312, 106, 647, 916, 377, 42, 643, 980, 381, 45, 704, 979, 318, 48, 769, 974, 255, 113, 772, 911, 250, 117, 836, 907, 186, 54, 835, 968, 189, 57, 896, 967, 126, 60, 961, 962, 63, 124, 965, 898, 59, 123, 902, 901, 120, 185, 904, 839, 118, 188, 969, 834, 55, 252, 973, 770, 51, 251, 910, 773, 112, 246, 847, 776, 177, 183, 842, 841, 180, 179, 778, 845, 244, 240, 781, 782, 243, 304, 785, 718, 239, 369, 788, 655, 234, 373, 852, 651, 170, 310, 851, 712, 173, 313, 912, 711, 110, 316, 977, 706, 47, 380, 981, 642, 43, 379, 918, 645, 104, 441, 920, 583, 102, 444, 985, 578, 39, 508, 989, 514, 35, 507, 926, 517, 96, 502, 863, 520, 161, 439, 858, 585, 164, 435, 794, 589, 228, 496, 797, 526, 227, 495, 734, 529, 288, 490, 671, 532, 353, 426, 667, 596, 357, 429, 728, 595, 294, 366, 727, 656, 297, 303, 722, 721, 300, 299, 658, 725, 364, 360, 661, 662, 363, 358, 599, 664, 425, 295, 594, 729, 428, 291, 530, 733, 492, 352, 533, 670, 491, 417, 536, 607, 486, 420, 601, 602, 423, 484, 605, 538, 419, 483, 542, 541, 480, 545, 544, 479, 478, 548, 609, 474, 415, 612, 613, 410, 411, 611, 550, 413, 472, 672, 553, 350, 471, 737, 556, 287, 466, 741, 620, 283, 402, 678, 619, 344, 405, 680, 681, 342, 343, 745, 684, 279, 338, 749, 748, 275, 274, 686, 747, 336, 277, 623, 742, 401, 280, 618, 679, 404, 345, 554, 675, 468, 349, 557, 736, 467, 286, 560, 801, 462, 223, 625, 804, 399, 218, 629, 868, 395, 154, 566, 867, 456, 157, 569, 928, 455, 94, 572, 993, 450, 31, 636, 997, 386, 27, 635, 934, 389, 88, 697, 936, 327, 86, 700, 1001, 322, 23, 764, 1005, 258, 19, 763, 942, 261, 80, 758, 879, 264, 145, 695, 874, 329, 148, 691, 810, 333, 212, 752, 813, 270, 211, 816, 817, 206, 207, 881, 820, 143, 202, 885, 884, 139, 138, 822, 883, 200, 141, 825, 944, 199, 78, 828, 1009, 194, 15, 892, 1013, 130, 11, 891, 950, 133, 72, 953, 952, 71, 70, 956, 1017, 66, 7, 1020, 1021, 2, 3, 1019, 958, 5, 64, 1014, 895, 8, 129, 951, 890, 73, 132, 947, 826, 77, 196, 1008, 829, 14, 195, 1007, 766, 17, 256, 1002, 703, 20, 321, 938, 699, 84, 325, 941, 760, 83, 262, 878, 759, 144, 265, 815, 754, 209, 268, 811, 690, 213, 332, 872, 693, 150, 331, 870, 631, 152, 393, 807, 626, 217, 396, 803, 562, 221, 460, 864, 565, 158, 459, 929, 568, 95, 454, 932, 633, 90, 391, 996, 637, 26, 387, 995, 574, 29, 448, 990, 511, 32, 513, 927, 506, 97, 516, 923, 442, 101, 580, 984, 445, 38, 579, 983, 382, 41, 640, 978, 319, 44, 705, 914, 315, 108, 709, 917, 376, 107, 646, 855, 374, 169, 648, 850, 311, 172, 713, 786, 307, 236, 717, 789, 368, 235, 654, 792, 433, 230, 591, 857, 436, 167, 586, 861, 500, 163, 522, 798, 499, 224, 525, 735, 494, 289, 528, 730, 431, 292, 593, 666, 427, 356, 597, 669, 488, 355, 534, 606, 487, 416, 537, 543, 482, 481, 540, 539, 418, 485, 604, 600, 421, 422, 603, 598, 359, 424, 665, 535, 354, 489, 668, 531, 290, 493, 732, 592, 293, 430, 731, 657, 296, 367, 726, 660, 361, 362, 663, 724, 365, 298, 659, 723, 302, 301, 720, 719, 238, 305, 784, 714, 175, 308, 849, 650, 171, 372, 853, 653, 232, 371, 790, 590, 231, 432, 793, 527, 226, 497, 796, 523, 162, 501, 860, 584, 165, 438, 859, 582, 103, 440, 921, 519, 98, 505, 924, 515, 34, 509, 988, 576, 37, 446, 987, 641, 40, 383, 982, 644, 105, 378, 919, 708, 109, 314, 915, 707, 46, 317, 976, 768, 49, 254, 975, 833, 52, 191, 970, 837, 116, 187, 906, 774, 115, 248, 909, 777, 176, 247, 846, 780, 241, 242, 783, 844, 245, 178, 779, 843, 182, 181, 840, 905, 184, 119, 838, 908, 249, 114, 775, 972, 253, 50, 771, 971, 190, 53, 832, 966, 127, 56, 897, 903, 122, 121, 900, 899, 58, 125, 964, 960, 61, 62, 963]

  def new(id) do
    %CellId{id: rem(id, 0xffffffffffffffff)}
  end

  def from_lat_lng(%LatLng{} = latlng) do
    latlng
    |> LatLng.to_point
    |> CellId.from_point
  end

  def from_point(%Point{} = point) do
    {face, u, v} = Utilities.xyz_to_face_uv(point)
    i = CellId.st_to_ij(CellId.uv_to_st(u))
    j = CellId.st_to_ij(CellId.uv_to_st(v))
    CellId.from_face_ij(face, i, j)
  end

  def from_face_pos_level(face, pos, level) do
    (face <<< @pos_bits) + (pos ||| 1)
    |> CellId.new()
    |> CellId.parent(level)
  end

  def lookup_pos do
    0..((1 <<< (2 * @lookup_bits + 2))-1) |> Enum.to_list |> Enum.map(fn (_) -> nil end)
  end

  def from_face_ij(face, i, j) do
    n = face <<< (@pos_bits - 1)
    bits = face &&& @swap_mask
    {nbits, nn} = 7..0
    |> Enum.reduce({bits, n}, fn (k, {bits, n}) ->
      mask = (1 <<< @lookup_bits) - 1
      bits = bits + (((i >>> (k * @lookup_bits)) &&& mask) <<< (@lookup_bits + 2))
      bits = bits + (((j >>> (k * @lookup_bits)) &&& mask) <<< 2)
      bits = @lookup_pos |> Enum.at(bits)
      n = n ||| ((bits >>> 2) <<< (k * 2 * @lookup_bits))
      bits = bits &&& (@swap_mask ||| @invert_mask)
      {bits, n}
    end)

    CellId.new(nn * 2 + 1)
  end

  def from_face_ij_wrap(face, i, j) do
    i = max(-1, min(@max_size, i))
    j = max(-1, min(@max_size, j))

    scale = 1.0 / @max_size

    u = scale * ((i <<< 1) + 1 - @max_size)
    v = scale * ((j <<< 1) + 1 - @max_size)

    {face, u, v} = Utilities.face_uv_to_xyz(face, u, v) |> Utilities.xyz_to_face_uv

    CellId.from_face_ij(face, CellId.st_to_ij(0.5 * (u + 1)), CellId.st_to_ij(0.5 * (v + 1)))
  end

  def from_face_ij_same(face, i, j, same_face) do
    case same_face do
      true -> CellId.from_face_ij(face, i, j)
      false -> CellId.from_face_ij_wrap(face, i, j)
    end
  end

  def st_to_ij(s) do
    max(0, min(@max_size - 1, round(Float.floor(@max_size * s))))
  end

  def lsb_for_level(level) do
    1 <<< (2 * (@max_level - level))
  end

  def parent(%CellId{} = cell_id) do
    new_lsb = CellId.lsb(cell_id) <<< 2
    CellId.new((cell_id.id &&& -new_lsb) ||| new_lsb)
  end

  def parent(%CellId{} = cell_id, level) do
    new_lsb = CellId.lsb_for_level(level)
    CellId.new((cell_id.id &&& -new_lsb) ||| new_lsb)
  end

  def child(%CellId{} = cell_id, pos) do
    new_lsb = CellId.lsb(cell_id) >>> 2
    CellId.new(cell_id.id + (2 * pos + 1 - 4) * new_lsb)
  end

  def contains(%CellId{} = cell_id, %CellId{id: other_id} = other_cell_id) do
    {range_min, range_max} = {cell_id |> CellId.range_min, cell_id |> CellId.range_max}
    other_id >= range_min.id && other_id <= range_max.id
  end

  def intersects(%CellId{} = cell_id, %CellId{} = other_cell_id) do

  end

  def is_face(%CellId{} = cell_id) do
    (cell_id.id &&& (CellId.lsb_for_level(0) - 1)) == 0
  end

  def id(%CellId{id: id}), do: id

  def is_valid(%CellId{} = cell_id) do

  end

  def lsb(%CellId{} = cell_id) do
    cell_id.id &&& -cell_id.id
  end

  def face(%CellId{id: id} = cell_id) do
    id >>> @pos_bits
  end

  def pos(%CellId{id: id}), do: id &&& (0xffffffffffffffff >>> @face_bits)

  def is_leaf(%CellId{id: id}) do
    (id &&& 1) != 0
  end

  def level(%CellId{id: id} = cell_id) do
    case CellId.is_leaf(cell_id) do
      true -> @max_level
      false ->
        x = id &&& 0xffffffff
        level = -1
        {level, x} = case x != 0 do
          true -> {level + 16, x}
          false -> {level, (id >>> 32) &&& 0xffffffff}
        end
        x = (x &&& -x)

        level = case (x &&& 0x00005555) > 0 do
          true -> level + 8
          _ -> level
        end

        level = case (x &&& 0x00550055) > 0 do
          true -> level + 4
          _ -> level
        end

        level = case (x &&& 0x05050505) > 0 do
          true -> level + 2
          _ -> level
        end

        level = case (x &&& 0x11111111) > 0 do
          true -> level + 1
          _ -> level
        end

        level
    end
  end

  def child_begin(%CellId{id: id} = cell_id) do
    old_lsb = cell_id |> CellId.lsb
    CellId.new(id - old_lsb + (old_lsb >>> 2))
  end

  def child_begin(%CellId{id: id} = cell_id, level) do
    CellId.new(id - (cell_id |> CellId.lsb) + (level |> CellId.lsb_for_level))
  end

  def child_end(%CellId{id: id} = cell_id) do
    old_lsb = cell_id |> CellId.lsb
    CellId.new(id + old_lsb + (old_lsb >>> 2))
  end

  def child_end(%CellId{id: id} = cell_id, level) do
    CellId.new(id + (cell_id |> CellId.lsb) + (level |> CellId.lsb_for_level))
  end

  def prev(%CellId{id: id} = cell_id) do
    CellId.new(id - ((cell_id |> CellId.lsb) <<< 1))
  end

  def next(%CellId{id: id} = cell_id) do
    CellId.new(id + ((cell_id |> CellId.lsb) <<< 1))
  end

  def children(%CellId{} = cell_id) do
    start_cell = cell_id |> CellId.child_begin
    end_cell = cell_id |> CellId.child_end
    Stream.unfold(start_cell, fn (current_cell) ->
      case current_cell != end_cell do
        true -> {current_cell, CellId.next(current_cell)}
        false -> nil
      end
    end)
  end

  def children(%CellId{} = cell_id, level) do
    start_cell = cell_id |> CellId.child_begin(level)
    end_cell = cell_id |> CellId.child_end(level)
    Stream.unfold(start_cell, fn (current_cell) ->
      case current_cell != end_cell do
        true -> {current_cell, CellId.next(current_cell)}
        false -> nil
      end
    end)
  end

  def range_min(%CellId{id: id} = cell_id) do
    CellId.new(id - (CellId.lsb(cell_id) - 1))
  end

  def range_max(%CellId{id: id} = cell_id) do
    CellId.new(id + (CellId.lsb(cell_id) - 1))
  end

  def begin(level) do
    CellId.from_face_pos_level(0, 0, 0)
    |> CellId.child_begin(level)
  end

  def end1(level) do
    CellId.from_face_pos_level(5, 0, 0)
    |> CellId.child_end(level)
  end

  def none(%CellId{} = cell_id) do

  end

  def prev_wrap(%CellId{} = cell_id) do
    p = CellId.prev(cell_id)
    case CellId.id(p) < @wrap_offset do
      true ->
        p
      false ->
        CellId.new(CellId.id(p) + @wrap_offset)
    end
  end

  def next_wrap(%CellId{} = cell_id) do
    n = CellId.next(cell_id)
    case CellId.id(n) < @wrap_offset do
      true ->
        n
      false ->
        CellId.new(CellId.id(n) - @wrap_offset)
    end
  end

  #is unfinished
  def advance_wrap(%CellId{} = cell_id, steps) do
    step_shift = 2 * (@max_level - CellId.level(cell_id)) + 1
    cond do
      steps == 0 ->
        cell_id
      steps < 0 ->
        min_steps = -(CellId.id(cell_id) >>> step_shift)
        if steps < min_steps do
          step_wrap = @wrap_offset >>> step_shift
          if steps < min_steps do
            steps = steps - step_wrap
          end
        end
      steps > 0 ->
        max_steps = (@wrap_offset - CellId.id(cell_id)) >>> step_shift
        if steps > max_steps do
          step_wrap = @wrap_offset >>> step_shift
          if steps > max_steps do
            steps = steps - step_wrap
          end
        end
    end
  end

  def advance(%CellId{} = cell_id, steps) do

  end

  def to_lat_lng(%CellId{} = cell_id) do
    cell_id
    |> CellId.to_point_raw
    |> LatLng.from_point
  end

  def to_point_raw(%CellId{} = cell_id) do
    {face, si, ti} = cell_id |> CellId.get_center_si_ti
    Utilities.face_uv_to_xyz(
      face,
      ((0.5 / @max_size) * si) |> CellId.st_to_uv,
      ((0.5 / @max_size) * ti) |> CellId.st_to_uv
    )
  end

  def to_point(%CellId{} = cell_id) do
    cell_id
    |> CellId.to_point_raw()
    |> Point.normalize()
  end

  def get_center_si_ti(%CellId{id: id} = cell_id) do
    {face, i, j, orientation} = cell_id |> CellId.to_face_ij_orientation

    delta = cond do
      (cell_id |> CellId.is_leaf) == true -> 1
      ((i ^^^ (id >>> 2) &&& 1)) != 0 -> 2
      true -> 0
    end

    {face, 2 * i + delta, 2 * j + delta}
  end

  def get_center_uv(%CellId{} = cell_id) do

  end

  def to_face_ij_orientation(%CellId{id: id} = cell_id) do
    {i, j} = {0, 0}
    face = cell_id |> CellId.face
    bits = (face &&& @swap_mask)

    {i, j, bits} = 7..0
    |> Enum.reduce({i, j, bits}, fn(k, {i, j, bits}) ->
      nbits = case (k == 7) do
        true -> @max_level - 7 * @lookup_bits
        _ -> @lookup_bits
      end

      bits = bits + ((id >>> (k * 2 * @lookup_bits + 1) &&& ((1 <<< (2 * nbits)) - 1)) <<< 2)
      bits = @lookup_ij |> Enum.at(bits)
      i = i + ((bits >>> (@lookup_bits + 2)) <<< (k * @lookup_bits))
      j = j + (((bits >>> 2) &&& ((1 <<< @lookup_bits) - 1)) <<< (k * @lookup_bits))
      bits = bits &&& (@swap_mask ||| @invert_mask)
      {i, j, bits}
    end)

    bits = case ((cell_id |> CellId.lsb) &&& 0x1111111111111110) != 0 do
      true -> bits ^^^ @swap_mask
      _ -> bits
    end
    orientation = bits

    {face, i, j, orientation}
  end

  def get_edge_neighbors(%CellId{} = cell_id) do
    level = cell_id |> CellId.level
    size = cell_id |> CellId.get_size_ij(level)
    {face, i, j, orientation} = cell_id |> CellId.to_face_ij_orientation
    [
      CellId.from_face_ij_same(face, i, j - size, j - size >= 0) |> CellId.parent(level),
      CellId.from_face_ij_same(face, i + size, j, i + size < @max_size) |> CellId.parent(level),
      CellId.from_face_ij_same(face, i, j + size, j + size >= @max_size) |> CellId.parent(level),
      CellId.from_face_ij_same(face, i - size, j, i - size >= 0) |> CellId.parent(level)
    ]
  end

  def get_vertex_neighbors(%CellId{} = cell_id, level) do
    {face, i, j, orientation} = CellId.to_face_ij_orientation(cell_id)
    halfsize = CellId.get_size_ij(cell_id, level + 1)
    size = halfsize <<< 1
    case i &&& halfsize do
      1 ->
        ioffset = size
        isame = (i + size) < @max_size
      0 ->
        ioffset = -size
        isame = (i - size) >= 0
      _ ->
    end
    case j &&& halfsize do
      1 ->
        joffset = size
        jsame = (j + size) < @max_size
      0 ->
        joffset = -size
        jsame = (j - size) >= 0
      _ ->
    end
    neighbors = [CellId.parent(cell_id, level)]
    neighbors = neighbors ++ [
      CellId.from_face_ij_same(face, i + ioffset, j, isame)
      |> CellId.parent(level)
    ]
    neighbors = neighbors ++ [
      CellId.from_face_ij_same(face, i, j + joffset, jsame)
      |> CellId.parent(level)
    ]
    if isame or jsame do
      neighbors = neighbors ++ [
        CellId.from_face_ij_same(face, i + ioffset, j + joffset, isame and jsame)
        |> CellId.parent(level)
      ]
    end
  end

  def get_all_neighbors(%CellId{} = cell_id, nbr_level) do
    import Logger
    {face, i, j, orientation} = CellId.to_face_ij_orientation(cell_id)
    size = CellId.get_size_ij(cell_id)
    i = i &&& -size
    j = j &&& -size

    nbr_size = CellId.get_size_ij(cell_id, nbr_level)
    k = -nbr_size
    Stream.unfold({k, []}, fn ({k, list}) ->
      {same_face, vert} = cond do
        k < 0 -> { ((j + k) >= 0), [] }
        k >= size -> { ((j + k) < @max_size), [] }
        true -> { false, [CellId.from_face_ij_same(face, i+k, j-nbr_size, j-size >= 0) |> CellId.parent(nbr_level), CellId.from_face_ij_same(face, i+k, j+size, j+size < @max_size) |> CellId.parent(nbr_level)] }
      end
      vert = vert ++ [CellId.from_face_ij_same(face, i-nbr_size, j+k, (same_face) and (i-size >= 0)) |> CellId.parent(nbr_level), CellId.from_face_ij_same(face, i+size, j+k, (same_face) and (i+size < @max_size)) |> CellId.parent(nbr_level)]

      case (k >= size * 2) do
        true -> nil
        false -> {{k, vert}, {k + nbr_size, vert}}
      end
    end)
    |> Enum.map(fn({_, list}) -> list end)
    |> List.flatten
    |> Enum.to_list
  end

  def get_size_ij(%CellId{} = cell_id) do
    level = cell_id |> CellId.level
    CellId.get_size_ij(cell_id, level)
  end

  def get_size_ij(%CellId{} = cell_id, level) do
    1 <<< (@max_level - level)
  end

  def to_token(%CellId{id: id}) do
    Integer.to_charlist(id, 16)
    |> :erlang.list_to_binary()
    |> String.trim_trailing("0")
  end

  def from_token(token) do
    token
    |> String.ljust(16, ?0)
    |> Integer.parse(16)
    |> case do
      {id, _} -> id
      _ -> nil
    end
    |> CellId.new()
  end

  def st_to_uv(s) do
    case @projection do
      @linear_projection -> 2 * s - 1
      @tan_projection ->
        s = :math.tan((:math.pi / 2.0) * s - :math.pi / 4.0)
        s + (1.0 / (1 <<< 53)) * s
      @quadratic_projection ->
        case s >= 0.5 do
          true -> (1.0 / 3.0) * (4 * s * s - 1)
          _ -> (1.0 / 3.0) * (1 - 4 *(1 - s) * (1 - s))
        end
      _ -> raise "Unknown projection"
    end
  end

  def uv_to_st(u) do
    case @projection do
      @linear_projection -> 0.5 * (u + 1)
      @tan_projection ->
        (2 * (1.0 / :math.pi())) * (:math.atan(u) * :math.pi / 4.0)
      @quadratic_projection ->
        case u >= 0 do
          true ->
            0.5 * :math.sqrt(1 + 3 * u)
          false ->
            1 - 0.5 * :math.sqrt(1 - 3 * u)
        end
      _ ->
        raise "Unknown projection"
    end
  end

  def max_edge(%CellId{} = cell_id) do

  end

  def max_angle_span(%CellId{} = cell_id) do

  end

  def max_diag(%CellId{} = cell_id) do

  end

  def min_width(%CellId{} = cell_id) do

  end
end
