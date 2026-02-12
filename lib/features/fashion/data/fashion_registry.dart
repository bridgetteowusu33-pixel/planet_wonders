import 'dart:ui';

import '../models/fashion_data.dart';

// ---------------------------------------------------------------------------
// Africa
// ---------------------------------------------------------------------------

// Ghana — Dress Afia
const _ghanaFashion = FashionData(
  countryId: 'ghana',
  characterName: 'Afia',
  characterEmoji: '\u{1F467}\u{1F3FE}', // 👧🏾
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}', // 👗
      items: [
        OutfitItem(
          id: 'kente_dress',
          name: 'Kente Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'festival_dress',
          name: 'Festival Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF7A7A),
        ),
        OutfitItem(
          id: 'school_uniform',
          name: 'School Uniform',
          emoji: '\u{1F455}',
          color: Color(0xFF6EC6E9),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}', // 👕
      items: [
        OutfitItem(
          id: 'kente_top',
          name: 'Kente Top',
          emoji: '\u{1F455}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'adinkra_blouse',
          name: 'Adinkra Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFF9C27B0),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}', // 🩳
      items: [
        OutfitItem(
          id: 'kente_skirt',
          name: 'Kente Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'printed_wrap',
          name: 'Printed Wrap',
          emoji: '\u{1FA73}',
          color: Color(0xFF4CAF50),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}', // 👒
      items: [
        OutfitItem(
          id: 'headwrap',
          name: 'Headwrap',
          emoji: '\u{1F452}',
          color: Color(0xFFFF9800),
        ),
        OutfitItem(
          id: 'crown',
          name: 'Crown',
          emoji: '\u{1F451}', // 👑
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'beads',
      label: 'Beads',
      emoji: '\u{1F4FF}', // 📿
      items: [
        OutfitItem(
          id: 'trade_beads',
          name: 'Trade Beads',
          emoji: '\u{1F4FF}',
          color: Color(0xFFFF5722),
        ),
        OutfitItem(
          id: 'gold_necklace',
          name: 'Gold Necklace',
          emoji: '\u{1F4FF}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'shoes',
      label: 'Shoes',
      emoji: '\u{1F461}', // 👡
      items: [
        OutfitItem(
          id: 'sandals',
          name: 'Sandals',
          emoji: '\u{1FA74}', // 🩴
          color: Color(0xFF8D6E63),
        ),
        OutfitItem(
          id: 'beaded_slippers',
          name: 'Beaded Slippers',
          emoji: '\u{1F461}',
          color: Color(0xFFE91E63),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Kente cloth is woven by the Ashanti people. '
          'Each colour and pattern tells a different story!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Adinkra symbols are stamped onto cloth '
          'to share wisdom and proverbs.',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Ghanaian headwraps are worn for celebrations '
          'and special occasions.',
      category: 'Tradition',
    ),
    FashionFact(
      text: 'Trade beads have been used in Ghana for hundreds '
          'of years. They are very valuable!',
      category: 'History',
    ),
  ],
);

// Nigeria — Dress Adaeze
const _nigeriaFashion = FashionData(
  countryId: 'nigeria',
  characterName: 'Adaeze',
  characterEmoji: '\u{1F467}\u{1F3FE}', // 👧🏾
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'ankara_dress',
          name: 'Ankara Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF9800),
        ),
        OutfitItem(
          id: 'iro_buba',
          name: 'Iro & Buba',
          emoji: '\u{1F457}',
          color: Color(0xFF9C27B0),
        ),
        OutfitItem(
          id: 'aso_oke_dress',
          name: 'Aso Oke Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'ankara_blouse',
          name: 'Ankara Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFFF5722),
        ),
        OutfitItem(
          id: 'dashiki_top',
          name: 'Dashiki Top',
          emoji: '\u{1F455}',
          color: Color(0xFF4CAF50),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'ankara_wrapper',
          name: 'Ankara Wrapper',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF9800),
        ),
        OutfitItem(
          id: 'george_wrapper',
          name: 'George Wrapper',
          emoji: '\u{1FA73}',
          color: Color(0xFFE91E63),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'gele',
          name: 'Gele Headwrap',
          emoji: '\u{1F452}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'beaded_crown',
          name: 'Beaded Crown',
          emoji: '\u{1F451}',
          color: Color(0xFFFF5722),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Ankara fabric features bold, colourful patterns '
          'and is worn across West Africa!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'A Gele is an elaborate headwrap tied in many '
          'beautiful styles for special events.',
      category: 'Tradition',
    ),
    FashionFact(
      text: 'Aso Ebi means "family cloth" — groups of friends '
          'wear matching outfits at celebrations!',
      category: 'Culture',
    ),
  ],
);

// Kenya — Dress Amani
const _kenyaFashion = FashionData(
  countryId: 'kenya',
  characterName: 'Amani',
  characterEmoji: '\u{1F467}\u{1F3FE}', // 👧🏾
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'kikoi_dress',
          name: 'Kikoi Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'maasai_dress',
          name: 'Maasai Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'kanga_top',
          name: 'Kanga Top',
          emoji: '\u{1F455}',
          color: Color(0xFF4CAF50),
        ),
        OutfitItem(
          id: 'beaded_collar',
          name: 'Beaded Collar Top',
          emoji: '\u{1F455}',
          color: Color(0xFFFF9800),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'kikoi_wrap',
          name: 'Kikoi Wrap',
          emoji: '\u{1FA73}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'kitenge_skirt',
          name: 'Kitenge Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF9C27B0),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'maasai_headpiece',
          name: 'Maasai Beads',
          emoji: '\u{1F451}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'flower_crown_ke',
          name: 'Flower Crown',
          emoji: '\u{1F33A}', // 🌺
          color: Color(0xFFE91E63),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Maasai beadwork uses bright colours — each '
          'colour has a special meaning!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Kanga cloth has a saying printed on it. '
          'People use it to send messages!',
      category: 'Fun Fact',
    ),
    FashionFact(
      text: 'Kikoi is a woven cotton fabric from the '
          'Kenyan coast, used as wraps and scarves.',
      category: 'Culture',
    ),
  ],
);

// Egypt — Dress Nour
const _egyptFashion = FashionData(
  countryId: 'egypt',
  characterName: 'Nour',
  characterEmoji: '\u{1F467}\u{1F3FD}', // 👧🏽
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'galabiya',
          name: 'Galabiya Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF00BCD4),
        ),
        OutfitItem(
          id: 'pharaoh_dress',
          name: 'Pharaoh Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'embroidered_top_eg',
          name: 'Embroidered Top',
          emoji: '\u{1F455}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'linen_blouse',
          name: 'Linen Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFF5F5DC),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'harem_pants',
          name: 'Harem Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF9C27B0),
        ),
        OutfitItem(
          id: 'cotton_skirt_eg',
          name: 'Cotton Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF00BCD4),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F451}',
      items: [
        OutfitItem(
          id: 'nemes_headdress',
          name: 'Nemes Headdress',
          emoji: '\u{1F451}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'golden_headband',
          name: 'Golden Headband',
          emoji: '\u{1F451}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Ancient Egyptians wore linen — one of the '
          'oldest fabrics in the world!',
      category: 'History',
    ),
    FashionFact(
      text: 'Pharaohs wore a striped headdress called a '
          'Nemes to show their royal power.',
      category: 'History',
    ),
    FashionFact(
      text: 'Egyptians invented kohl eyeliner over '
          '5,000 years ago!',
      category: 'Fun Fact',
    ),
  ],
);

// South Africa — Dress Thandi
const _southAfricaFashion = FashionData(
  countryId: 'south_africa',
  characterName: 'Thandi',
  characterEmoji: '\u{1F467}\u{1F3FE}', // 👧🏾
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'shweshwe_dress',
          name: 'Shweshwe Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'xhosa_dress',
          name: 'Xhosa Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF9800),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'madiba_shirt',
          name: 'Madiba Shirt',
          emoji: '\u{1F455}',
          color: Color(0xFF4CAF50),
        ),
        OutfitItem(
          id: 'beaded_cape',
          name: 'Beaded Cape',
          emoji: '\u{1F455}',
          color: Color(0xFFFF4444),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'shweshwe_skirt',
          name: 'Shweshwe Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'printed_wrap_za',
          name: 'Printed Wrap',
          emoji: '\u{1FA73}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'isicholo',
          name: 'Zulu Isicholo',
          emoji: '\u{1F452}',
          color: Color(0xFF8D6E63),
        ),
        OutfitItem(
          id: 'doek',
          name: 'Doek Headscarf',
          emoji: '\u{1F452}',
          color: Color(0xFFE91E63),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Shweshwe fabric has tiny printed patterns '
          'and is South Africa\'s favourite cloth!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Zulu beadwork uses colours to send love '
          'letters — each colour means something different!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'The Madiba shirt was made famous by '
          'Nelson Mandela and is a symbol of peace.',
      category: 'History',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Asia
// ---------------------------------------------------------------------------

// Japan — Dress Yuki
const _japanFashion = FashionData(
  countryId: 'japan',
  characterName: 'Yuki',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F458}', // 👘
      items: [
        OutfitItem(
          id: 'kimono',
          name: 'Kimono',
          emoji: '\u{1F458}',
          color: Color(0xFFFF69B4),
        ),
        OutfitItem(
          id: 'yukata',
          name: 'Yukata',
          emoji: '\u{1F458}',
          color: Color(0xFF6EC6E9),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'haori_jacket',
          name: 'Haori Jacket',
          emoji: '\u{1F9E5}',
          color: Color(0xFF9C27B0),
        ),
        OutfitItem(
          id: 'sailor_top',
          name: 'Sailor Top',
          emoji: '\u{1F455}',
          color: Color(0xFF42A5F5),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'hakama',
          name: 'Hakama Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF2F3A4A),
        ),
        OutfitItem(
          id: 'pleated_skirt_jp',
          name: 'Pleated Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF607D8B),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'kasa_hat',
          name: 'Kasa Hat',
          emoji: '\u{1F452}',
          color: Color(0xFF8D6E63),
        ),
        OutfitItem(
          id: 'hair_ribbon_jp',
          name: 'Hair Ribbon',
          emoji: '\u{1F380}', // 🎀
          color: Color(0xFFFF69B4),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'A kimono has many layers and is tied '
          'with a wide belt called an obi!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Yukata are light cotton kimonos worn '
          'in summer and at festivals.',
      category: 'Tradition',
    ),
    FashionFact(
      text: 'Traditional Japanese wooden sandals '
          'called geta make a fun clip-clop sound!',
      category: 'Fun Fact',
    ),
  ],
);

// India — Dress Priya
const _indiaFashion = FashionData(
  countryId: 'india',
  characterName: 'Priya',
  characterEmoji: '\u{1F467}\u{1F3FD}', // 👧🏽
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'lehenga',
          name: 'Lehenga',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'salwar_kameez',
          name: 'Salwar Kameez',
          emoji: '\u{1F457}',
          color: Color(0xFF4CAF50),
        ),
        OutfitItem(
          id: 'anarkali',
          name: 'Anarkali Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF9C27B0),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'choli_blouse',
          name: 'Choli Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFFF9800),
        ),
        OutfitItem(
          id: 'kurti',
          name: 'Kurti Top',
          emoji: '\u{1F455}',
          color: Color(0xFF00BCD4),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'churidar',
          name: 'Churidar Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'ghagra_skirt',
          name: 'Ghagra Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF69B4),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'dupatta',
          name: 'Dupatta Scarf',
          emoji: '\u{1F9E3}', // 🧣
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'maang_tikka',
          name: 'Maang Tikka',
          emoji: '\u{1F48E}', // 💎
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'A sari is one long piece of fabric — up to '
          '9 metres — draped around the body!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Henna (mehndi) patterns are painted on hands '
          'and feet for weddings and festivals.',
      category: 'Tradition',
    ),
    FashionFact(
      text: 'India has been weaving silk for over '
          '5,000 years!',
      category: 'History',
    ),
  ],
);

// South Korea — Dress Minji
const _southKoreaFashion = FashionData(
  countryId: 'south_korea',
  characterName: 'Minji',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'hanbok',
          name: 'Hanbok',
          emoji: '\u{1F457}',
          color: Color(0xFFFF69B4),
        ),
        OutfitItem(
          id: 'modern_hanbok',
          name: 'Modern Hanbok',
          emoji: '\u{1F457}',
          color: Color(0xFF6EC6E9),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'jeogori',
          name: 'Jeogori Top',
          emoji: '\u{1F455}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'school_blazer_kr',
          name: 'School Blazer',
          emoji: '\u{1F455}',
          color: Color(0xFF2F3A4A),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'chima_skirt',
          name: 'Chima Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF69B4),
        ),
        OutfitItem(
          id: 'wide_pants_kr',
          name: 'Wide Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF607D8B),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F451}',
      items: [
        OutfitItem(
          id: 'jokduri',
          name: 'Jokduri Crown',
          emoji: '\u{1F451}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'ribbon_headband_kr',
          name: 'Ribbon Headband',
          emoji: '\u{1F380}',
          color: Color(0xFFFF69B4),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'The hanbok has been worn in Korea for over '
          '1,600 years! The skirt is called a chima.',
      category: 'History',
    ),
    FashionFact(
      text: 'Norigae are decorative knot ornaments '
          'that hang from a hanbok — like a lucky charm!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Korean jogakbo is patchwork made from tiny '
          'scraps of fabric sewn together beautifully.',
      category: 'Culture',
    ),
  ],
);

// China — Dress Mei
const _chinaFashion = FashionData(
  countryId: 'china',
  characterName: 'Mei',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'qipao',
          name: 'Qipao',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'hanfu',
          name: 'Hanfu',
          emoji: '\u{1F457}',
          color: Color(0xFF6EC6E9),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'mandarin_top',
          name: 'Mandarin Top',
          emoji: '\u{1F455}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'tang_jacket',
          name: 'Tang Jacket',
          emoji: '\u{1F9E5}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'silk_pants',
          name: 'Silk Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF9C27B0),
        ),
        OutfitItem(
          id: 'pleated_skirt_cn',
          name: 'Pleated Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF69B4),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'hair_chopsticks',
          name: 'Hair Chopsticks',
          emoji: '\u{1F962}', // 🥢
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'flower_crown_cn',
          name: 'Flower Crown',
          emoji: '\u{1F33A}',
          color: Color(0xFFFF69B4),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Silk was invented in China over 5,000 years '
          'ago and was once worth more than gold!',
      category: 'History',
    ),
    FashionFact(
      text: 'The qipao (cheongsam) has a beautiful '
          'high collar and frog-button closures.',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Hanfu is the traditional clothing of the '
          'Han Chinese, with flowing sleeves and sashes.',
      category: 'History',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Europe
// ---------------------------------------------------------------------------

// Italy — Dress Sofia
const _italyFashion = FashionData(
  countryId: 'italy',
  characterName: 'Sofia',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'venetian_dress',
          name: 'Venetian Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF9C27B0),
        ),
        OutfitItem(
          id: 'sundress_it',
          name: 'Sundress',
          emoji: '\u{1F457}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'striped_mariniere_it',
          name: 'Marinière',
          emoji: '\u{1F455}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'lace_blouse',
          name: 'Lace Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFF5F5DC),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'tailored_trousers',
          name: 'Tailored Trousers',
          emoji: '\u{1FA73}',
          color: Color(0xFF2F3A4A),
        ),
        OutfitItem(
          id: 'pleated_skirt_it',
          name: 'Pleated Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF4444),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'straw_hat_it',
          name: 'Straw Sun Hat',
          emoji: '\u{1F452}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'carnival_mask',
          name: 'Carnival Mask',
          emoji: '\u{1F3AD}', // 🎭
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Italy is the fashion capital of the world! '
          'Milan hosts huge fashion shows every year.',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Venetian carnival masks have been worn '
          'since the 13th century!',
      category: 'History',
    ),
    FashionFact(
      text: 'The city of Como in Italy has been making '
          'beautiful silk fabric for over 500 years.',
      category: 'History',
    ),
  ],
);

// France — Dress Camille
const _franceFashion = FashionData(
  countryId: 'france',
  characterName: 'Camille',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'breton_dress',
          name: 'Breton Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'floral_frock',
          name: 'Floral Frock',
          emoji: '\u{1F457}',
          color: Color(0xFFFF69B4),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'mariniere',
          name: 'Marinière Top',
          emoji: '\u{1F455}',
          color: Color(0xFF2F3A4A),
        ),
        OutfitItem(
          id: 'peter_pan_blouse',
          name: 'Peter Pan Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFF5F5DC),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'culottes',
          name: 'Culottes',
          emoji: '\u{1FA73}',
          color: Color(0xFF2F3A4A),
        ),
        OutfitItem(
          id: 'pleated_skirt_fr',
          name: 'Pleated Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF607D8B),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'beret',
          name: 'Beret',
          emoji: '\u{1F9E2}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'ribbon_bow_fr',
          name: 'Ribbon Bow',
          emoji: '\u{1F380}',
          color: Color(0xFFFF69B4),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Paris invented "haute couture" — fancy '
          'custom-made clothing for fashion shows!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'The French beret has been worn since the '
          '1400s by shepherds in the mountains.',
      category: 'History',
    ),
    FashionFact(
      text: 'Breton stripes were first worn by French '
          'sailors to spot them if they fell overboard!',
      category: 'Fun Fact',
    ),
  ],
);

// United Kingdom — Dress Olivia
const _ukFashion = FashionData(
  countryId: 'uk',
  characterName: 'Olivia',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'tartan_dress',
          name: 'Tartan Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'school_pinafore',
          name: 'School Pinafore',
          emoji: '\u{1F457}',
          color: Color(0xFF607D8B),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'cricket_jumper',
          name: 'Cricket Jumper',
          emoji: '\u{1F9E5}',
          color: Color(0xFFF5F5DC),
        ),
        OutfitItem(
          id: 'blazer_uk',
          name: 'Blazer',
          emoji: '\u{1F455}',
          color: Color(0xFF2F3A4A),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'tartan_kilt',
          name: 'Tartan Kilt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'school_trousers',
          name: 'School Trousers',
          emoji: '\u{1FA73}',
          color: Color(0xFF607D8B),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F451}',
      items: [
        OutfitItem(
          id: 'royal_crown_uk',
          name: 'Royal Crown',
          emoji: '\u{1F451}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'rain_hat',
          name: 'Rain Hat',
          emoji: '\u{1F9E2}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Scottish tartan patterns are unique to each '
          'clan — like a family uniform!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'The British Royal Family have special outfits '
          'for every occasion, even hat rules!',
      category: 'Fun Fact',
    ),
    FashionFact(
      text: 'Wellington boots ("wellies") were invented '
          'for the Duke of Wellington in 1817.',
      category: 'History',
    ),
  ],
);

// Spain — Dress Isabella
const _spainFashion = FashionData(
  countryId: 'spain',
  characterName: 'Isabella',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'flamenco_dress',
          name: 'Flamenco Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'sevillana_dress',
          name: 'Sevillana Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF9800),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'ruffled_blouse',
          name: 'Ruffled Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFF5F5DC),
        ),
        OutfitItem(
          id: 'bolero_jacket',
          name: 'Bolero Jacket',
          emoji: '\u{1F9E5}',
          color: Color(0xFF2F3A4A),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'flamenco_skirt',
          name: 'Flamenco Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'polka_dot_skirt',
          name: 'Polka Dot Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF2F3A4A),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'mantilla_comb',
          name: 'Mantilla Comb',
          emoji: '\u{1F452}',
          color: Color(0xFF2F3A4A),
        ),
        OutfitItem(
          id: 'flower_pin_es',
          name: 'Flower Hair Pin',
          emoji: '\u{1F33A}',
          color: Color(0xFFFF4444),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Flamenco dresses have ruffled layers that '
          'swirl beautifully during dancing!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'A mantilla is a lace veil worn with a '
          'decorative comb for special celebrations.',
      category: 'Tradition',
    ),
    FashionFact(
      text: 'Espadrilles are rope-soled shoes from Spain '
          'that have been worn for 700 years!',
      category: 'History',
    ),
  ],
);

// ---------------------------------------------------------------------------
// North America
// ---------------------------------------------------------------------------

// Mexico — Dress Valentina
const _mexicoFashion = FashionData(
  countryId: 'mexico',
  characterName: 'Valentina',
  characterEmoji: '\u{1F467}\u{1F3FD}', // 👧🏽
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'china_poblana',
          name: 'China Poblana',
          emoji: '\u{1F457}',
          color: Color(0xFF4CAF50),
        ),
        OutfitItem(
          id: 'huipil_dress',
          name: 'Huipil Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF9800),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'embroidered_blouse_mx',
          name: 'Embroidered Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFF5F5DC),
        ),
        OutfitItem(
          id: 'folkloric_top',
          name: 'Folkloric Top',
          emoji: '\u{1F455}',
          color: Color(0xFFFF4444),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'colorful_skirt_mx',
          name: 'Colorful Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF9C27B0),
        ),
        OutfitItem(
          id: 'rebozo_wrap',
          name: 'Rebozo Wrap',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF5722),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'sombrero',
          name: 'Sombrero',
          emoji: '\u{1F452}',
          color: Color(0xFF8D6E63),
        ),
        OutfitItem(
          id: 'flower_crown_mx',
          name: 'Flower Crown',
          emoji: '\u{1F33A}',
          color: Color(0xFFE91E63),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Huipil is a handwoven tunic — each village '
          'has its own unique patterns and colours!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'The sombrero has a wide brim to protect '
          'from the sun. "Sombra" means shade!',
      category: 'Fun Fact',
    ),
    FashionFact(
      text: 'Mexican embroidery uses bright flowers '
          'and animals — each stitch tells a story.',
      category: 'Culture',
    ),
  ],
);

// USA — Dress Ava
const _usaFashion = FashionData(
  countryId: 'usa',
  characterName: 'Ava',
  characterEmoji: '\u{1F469}', // 👩
  bodyAsset: 'assets/characters/Ava/ava.png',
  bodyShiftY: -0.14,
  bodyScale: 1.50,
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}', // 👗
      items: [
        OutfitItem(
          id: 'summer_dress',
          name: 'Summer Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF6EC6E9),
          assetPath: 'assets/clothes/USA/dresses/summer_dress.png',
          shiftY: 0.35,
          scale: 0.68,
        ),
        OutfitItem(
          id: 'fourth_july',
          name: '4th of July',
          emoji: '\u{1F457}',
          color: Color(0xFFFF7A7A),
          assetPath: 'assets/clothes/USA/dresses/july_4_dress.png',
          shiftY: 0.29,
          scale: 0.82,
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}', // 👕
      items: [
        OutfitItem(
          id: 'hoodie',
          name: 'Hoodie',
          emoji: '\u{1F9E5}', // 🧥
          color: Color(0xFF9C27B0),
          assetPath: 'assets/clothes/USA/tops/hoodie.png',
          shiftY: 0.21,
          scale: 0.69,
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1F456}', // 👖
      items: [
        OutfitItem(
          id: 'jeans',
          name: 'Jeans',
          emoji: '\u{1F456}',
          color: Color(0xFF42A5F5),
          assetPath: 'assets/clothes/USA/bottoms/jeans.png',
          shiftY: 0.32,
          scale: 0.82,
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F9E2}', // 🧢
      items: [
        OutfitItem(
          id: 'baseball_cap',
          name: 'Baseball Cap',
          emoji: '\u{1F9E2}',
          color: Color(0xFFFF7A7A),
          assetPath: 'assets/clothes/USA/hats/baseball_cap.png',
          shiftY: -0.18,
          scale: 0.73,
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Blue jeans were invented in America in 1873 '
          'by Levi Strauss and Jacob Davis!',
      category: 'History',
    ),
    FashionFact(
      text: 'Baseball caps became popular in the 1860s '
          'when the Brooklyn Excelsiors wore them.',
      category: 'History',
    ),
    FashionFact(
      text: 'Cowboy boots were designed for riding horses. '
          'The pointed toe helps slide into stirrups!',
      category: 'Fun Fact',
    ),
    FashionFact(
      text: 'The hoodie was invented in the 1930s '
          'to keep workers warm in freezing warehouses.',
      category: 'History',
    ),
  ],
);

// Canada — Dress Emma
const _canadaFashion = FashionData(
  countryId: 'canada',
  characterName: 'Emma',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'plaid_dress_ca',
          name: 'Plaid Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'winter_coat_dress',
          name: 'Winter Coat',
          emoji: '\u{1F9E5}',
          color: Color(0xFF42A5F5),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'flannel_shirt',
          name: 'Flannel Shirt',
          emoji: '\u{1F455}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'hockey_jersey',
          name: 'Hockey Jersey',
          emoji: '\u{1F455}',
          color: Color(0xFF42A5F5),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'denim_overalls',
          name: 'Denim Overalls',
          emoji: '\u{1FA73}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'snow_pants',
          name: 'Snow Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF2F3A4A),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F9E2}',
      items: [
        OutfitItem(
          id: 'toque',
          name: 'Toque',
          emoji: '\u{1F9E2}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'mountie_hat',
          name: 'Mountie Hat',
          emoji: '\u{1F452}',
          color: Color(0xFF8D6E63),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Canadians call a knitted winter hat a "toque" '
          '— it keeps ears warm at -30\u00B0C!',
      category: 'Fun Fact',
    ),
    FashionFact(
      text: 'Cowichan sweaters are hand-knit by Indigenous '
          'peoples on Vancouver Island.',
      category: 'Culture',
    ),
    FashionFact(
      text: 'The iconic red Mountie uniform has been '
          'worn by the Royal Canadian Police since 1873.',
      category: 'History',
    ),
  ],
);

// ---------------------------------------------------------------------------
// South America
// ---------------------------------------------------------------------------

// Brazil — Dress Luna
const _brazilFashion = FashionData(
  countryId: 'brazil',
  characterName: 'Luna',
  characterEmoji: '\u{1F467}\u{1F3FD}', // 👧🏽
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'carnival_costume',
          name: 'Carnival Costume',
          emoji: '\u{1F457}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'baiana_dress',
          name: 'Baiana Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFF5F5DC),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'tropical_top',
          name: 'Tropical Top',
          emoji: '\u{1F455}',
          color: Color(0xFF4CAF50),
        ),
        OutfitItem(
          id: 'capoeira_top',
          name: 'Capoeira Top',
          emoji: '\u{1F455}',
          color: Color(0xFFF5F5DC),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'carnival_skirt',
          name: 'Carnival Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF9800),
        ),
        OutfitItem(
          id: 'ruffled_saia',
          name: 'Ruffled Saia',
          emoji: '\u{1FA73}',
          color: Color(0xFF4CAF50),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'carnival_headpiece',
          name: 'Carnival Headdress',
          emoji: '\u{1F451}',
          color: Color(0xFFFFD84D),
        ),
        OutfitItem(
          id: 'flower_crown_br',
          name: 'Flower Crown',
          emoji: '\u{1F33A}',
          color: Color(0xFFE91E63),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Carnival costumes can have over 1,000 feathers '
          'and take months to make!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Baiana women wear big layered white dresses '
          'with colourful beaded necklaces.',
      category: 'Tradition',
    ),
    FashionFact(
      text: 'Havaianas flip-flops are a Brazilian invention '
          'worn by millions around the world!',
      category: 'Fun Fact',
    ),
  ],
);

// Peru — Dress Sol
const _peruFashion = FashionData(
  countryId: 'peru',
  characterName: 'Sol',
  characterEmoji: '\u{1F467}\u{1F3FD}', // 👧🏽
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'pollera_dress',
          name: 'Pollera Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'manta_dress',
          name: 'Manta Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF9C27B0),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'poncho_pe',
          name: 'Poncho',
          emoji: '\u{1F9E5}',
          color: Color(0xFFFF5722),
        ),
        OutfitItem(
          id: 'embroidered_blouse_pe',
          name: 'Embroidered Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFF5F5DC),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'pollera_skirt',
          name: 'Pollera Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'woven_pants_pe',
          name: 'Woven Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF795548),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'montera_hat',
          name: 'Montera Hat',
          emoji: '\u{1F452}',
          color: Color(0xFFFF4444),
        ),
        OutfitItem(
          id: 'chullo',
          name: 'Chullo Hat',
          emoji: '\u{1F9E2}',
          color: Color(0xFFFF9800),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'Peruvian chullo hats have ear flaps and are '
          'knitted from warm alpaca wool!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Alpacas in Peru provide some of the softest '
          'wool in the world!',
      category: 'Fun Fact',
    ),
    FashionFact(
      text: 'Ancient Inca people made textiles so fine '
          'they were considered more precious than gold.',
      category: 'History',
    ),
  ],
);

// Colombia — Dress Catalina
const _colombiaFashion = FashionData(
  countryId: 'colombia',
  characterName: 'Catalina',
  characterEmoji: '\u{1F467}\u{1F3FD}', // 👧🏽
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'cumbia_dress',
          name: 'Cumbia Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF9800),
        ),
        OutfitItem(
          id: 'pollera_co',
          name: 'Pollera Dress',
          emoji: '\u{1F457}',
          color: Color(0xFFFF4444),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'ruana_poncho',
          name: 'Ruana Poncho',
          emoji: '\u{1F9E5}',
          color: Color(0xFF795548),
        ),
        OutfitItem(
          id: 'colorful_blouse_co',
          name: 'Colorful Blouse',
          emoji: '\u{1F455}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'wide_skirt_co',
          name: 'Wide Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFFFF9800),
        ),
        OutfitItem(
          id: 'printed_pants_co',
          name: 'Printed Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF4CAF50),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'sombrero_vueltiao',
          name: 'Vueltiao Hat',
          emoji: '\u{1F452}',
          color: Color(0xFF2F3A4A),
        ),
        OutfitItem(
          id: 'flower_crown_co',
          name: 'Flower Crown',
          emoji: '\u{1F33A}',
          color: Color(0xFFE91E63),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'The sombrero vueltiao is woven from a palm '
          'plant and is Colombia\'s national hat!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'The ruana is a warm poncho-like wrap worn '
          'in the cool Andes mountains.',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Wayuu mochila bags are hand-woven by '
          'Indigenous women and take weeks to make!',
      category: 'Culture',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Oceania
// ---------------------------------------------------------------------------

// Australia — Dress Ruby
const _australiaFashion = FashionData(
  countryId: 'australia',
  characterName: 'Ruby',
  characterEmoji: '\u{1F467}\u{1F3FB}', // 👧🏻
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'bush_dress',
          name: 'Bush Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF8D6E63),
        ),
        OutfitItem(
          id: 'beach_dress_au',
          name: 'Beach Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF00BCD4),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'surf_rashie',
          name: 'Surf Rashie',
          emoji: '\u{1F455}',
          color: Color(0xFF42A5F5),
        ),
        OutfitItem(
          id: 'cork_vest',
          name: 'Cork Vest',
          emoji: '\u{1F455}',
          color: Color(0xFF8D6E63),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'board_shorts',
          name: 'Board Shorts',
          emoji: '\u{1FA73}',
          color: Color(0xFF00BCD4),
        ),
        OutfitItem(
          id: 'bush_pants',
          name: 'Bush Pants',
          emoji: '\u{1FA73}',
          color: Color(0xFF8D6E63),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'akubra',
          name: 'Akubra Hat',
          emoji: '\u{1F452}',
          color: Color(0xFF8D6E63),
        ),
        OutfitItem(
          id: 'sun_hat_au',
          name: 'Sun Hat',
          emoji: '\u{1F452}',
          color: Color(0xFFFFD84D),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'The Akubra hat is made from rabbit fur felt '
          'and protects from the hot Aussie sun!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'Aboriginal dot paintings inspire fashion '
          'with stories told through coloured dots.',
      category: 'Culture',
    ),
    FashionFact(
      text: 'UGG boots were invented by Australian surfers '
          'to warm their feet after surfing!',
      category: 'Fun Fact',
    ),
  ],
);

// New Zealand — Dress Aroha
const _newZealandFashion = FashionData(
  countryId: 'new_zealand',
  characterName: 'Aroha',
  characterEmoji: '\u{1F467}\u{1F3FD}', // 👧🏽
  categories: [
    OutfitCategory(
      id: 'dress',
      label: 'Dress',
      emoji: '\u{1F457}',
      items: [
        OutfitItem(
          id: 'korowai_cloak',
          name: 'Korowai Cloak',
          emoji: '\u{1F457}',
          color: Color(0xFF795548),
        ),
        OutfitItem(
          id: 'kiwi_dress',
          name: 'Kiwi Dress',
          emoji: '\u{1F457}',
          color: Color(0xFF4CAF50),
        ),
      ],
    ),
    OutfitCategory(
      id: 'tops',
      label: 'Tops',
      emoji: '\u{1F455}',
      items: [
        OutfitItem(
          id: 'flax_woven_top',
          name: 'Flax Woven Top',
          emoji: '\u{1F455}',
          color: Color(0xFF4CAF50),
        ),
        OutfitItem(
          id: 'rugby_jersey',
          name: 'Rugby Jersey',
          emoji: '\u{1F455}',
          color: Color(0xFF2F3A4A),
        ),
      ],
    ),
    OutfitCategory(
      id: 'bottoms',
      label: 'Bottoms',
      emoji: '\u{1FA73}',
      items: [
        OutfitItem(
          id: 'piupiu_skirt',
          name: 'Piupiu Skirt',
          emoji: '\u{1FA73}',
          color: Color(0xFF795548),
        ),
        OutfitItem(
          id: 'sport_shorts_nz',
          name: 'Sport Shorts',
          emoji: '\u{1FA73}',
          color: Color(0xFF2F3A4A),
        ),
      ],
    ),
    OutfitCategory(
      id: 'hats',
      label: 'Hats',
      emoji: '\u{1F452}',
      items: [
        OutfitItem(
          id: 'feather_headpiece',
          name: 'Feather Headpiece',
          emoji: '\u{1FAB6}', // 🪶
          color: Color(0xFF2F3A4A),
        ),
        OutfitItem(
          id: 'koru_headband',
          name: 'Koru Headband',
          emoji: '\u{1F33F}', // 🌿
          color: Color(0xFF4CAF50),
        ),
      ],
    ),
  ],
  facts: [
    FashionFact(
      text: 'A piupiu skirt is made from rolled flax '
          'leaves and worn during M\u0101ori dances!',
      category: 'Culture',
    ),
    FashionFact(
      text: 'The korowai cloak is adorned with feathers '
          'and is a sign of great honour.',
      category: 'Tradition',
    ),
    FashionFact(
      text: 'New Zealand\'s All Blacks rugby team performs '
          'the haka dance before every game!',
      category: 'Fun Fact',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Registry
// ---------------------------------------------------------------------------

/// All fashion data keyed by country ID.
final Map<String, FashionData> fashionRegistry = {
  // Africa
  'ghana': _ghanaFashion,
  'nigeria': _nigeriaFashion,
  'kenya': _kenyaFashion,
  'egypt': _egyptFashion,
  'south_africa': _southAfricaFashion,
  // Asia
  'japan': _japanFashion,
  'india': _indiaFashion,
  'south_korea': _southKoreaFashion,
  'china': _chinaFashion,
  // Europe
  'italy': _italyFashion,
  'france': _franceFashion,
  'uk': _ukFashion,
  'spain': _spainFashion,
  // North America
  'mexico': _mexicoFashion,
  'usa': _usaFashion,
  'canada': _canadaFashion,
  // South America
  'brazil': _brazilFashion,
  'peru': _peruFashion,
  'colombia': _colombiaFashion,
  // Oceania
  'australia': _australiaFashion,
  'new_zealand': _newZealandFashion,
};

/// Quick lookup.
FashionData? findFashion(String countryId) => fashionRegistry[countryId];
