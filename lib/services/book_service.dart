import '../models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final List<Book> _books = [
    Book(
      id: '1',
      title: 'Assassin\'s Creed: Renaissance',
      author: 'Oliver Bowden',
      coverImage: 'assets/img/assasin.jpg',
      description: 'Betrayed by the ruling families of Italy, a young man embarks upon an epic quest for vengeance. To eradicate corruption and restore his family\'s honor, he will learn the art of the Assassins.',
      rating: 4.5,
      tags: ['Action', 'Adventure', 'Historical'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: The Beginning',
          content: '''Florence, 1476. The city gleamed in the morning sun, its towers and domes rising majestically against the azure sky. Young Ezio Auditore da Firenze walked through the bustling streets, unaware that his life was about to change forever.

The marketplace was alive with activity. Merchants called out their wares, children played in the shadows of grand buildings, and the scent of fresh bread mixed with the earthy smell of leather and spices.

Ezio was a carefree youth, the son of a wealthy banker. His days were filled with sword practice, flirtation with the local girls, and the occasional brawl with rival families. He lived a life of privilege, never questioning the stability of his world.

But dark forces were at work in the shadows of Florence. Conspiracies brewing in the noble houses would soon tear apart everything Ezio held dear. His family's honor, their very lives, hung in the balance of political intrigue and ancient rivalries.

As he walked through the Piazza della Signoria, past the great statue of David, Ezio had no idea that within days, his life would be transformed. He would lose everything he knew, and in that loss, would find his true purpose.

The path of the Assassin awaited him, though he did not yet know it. His journey from nobleman's son to master assassin would be long and filled with pain, but it would also be glorious.''',
          chapterNumber: 1,
        ),
        Chapter(
          id: 'c2',
          title: 'Chapter 2: Betrayal',
          content: '''The morning started like any other, but by evening, Ezio's world lay in ruins. His father and brothers were arrested on false charges of treason, victims of a conspiracy that reached the highest levels of Florentine power.

Ezio rushed to the Palazzo della Signoria, desperate to save his family. He watched helplessly as his father Giovanni and his brothers were led to the gallows. His pleas for mercy fell on deaf ears.

"Father!" Ezio cried out, his voice breaking with anguish.

Giovanni Auditore looked at his son one last time. Even in his final moments, he stood with dignity. "Be strong, Ezio. Protect your mother and sister. And remember, nothing is true, everything is permitted."

Those cryptic last words would echo in Ezio's mind for years to come. As the trapdoor opened and his family fell, something inside Ezio died as well. The carefree youth was gone forever.

In that moment of profound loss, a new Ezio was born. One driven by vengeance, but also by a desire to understand the conspiracy that had destroyed his family. He would learn that his father had been more than a banker – he had been an Assassin, part of an ancient order dedicated to fighting tyranny.

Now, that legacy fell to Ezio. He would take up his father's hidden blade and continue the fight. His path would lead him across Italy, from Florence to Venice, Rome and beyond, as he hunted those responsible for his family's death.

The training would be hard. The enemies would be many. But Ezio Auditore would become the greatest Assassin the Brotherhood had ever known.''',
          chapterNumber: 2,
        ),
        Chapter(
          id: 'c3',
          title: 'Chapter 3: The Brotherhood',
          content: '''Monteriggioni stood as a fortress town in the Tuscan hills, its walls strong and its people loyal. Here, Ezio found refuge with his uncle Mario, a man he had known only as a jovial relative. Now, Mario revealed himself as a Master Assassin.

"Welcome to the true family business, nipote," Mario said with a grim smile, leading Ezio through underground passages beneath the villa.

The hidden sanctuary took Ezio's breath away. Ancient weapons lined the walls, and a massive mural depicted the history of the Assassin Brotherhood stretching back millennia. Here were the secrets his father had kept hidden.

"The Assassins and Templars have been at war since the time of the Ancients," Mario explained. "Your father was one of our best. Now, you must take his place."

Training began at dawn. Ezio learned to move like a shadow, to scale walls like a spider, to strike with the precision of a serpent. The hidden blade became an extension of his arm. He mastered the art of blending into crowds, of disappearing in plain sight.

But the training was more than physical. Mario taught him to question everything, to see beyond surface truths. "Nothing is true, everything is permitted," Mario repeated. "These are not words of chaos, but of ultimate wisdom. We are not free to do as we wish. We are free to do what is right."

As weeks turned to months, Ezio transformed. His body grew strong and his mind sharp. But more than that, he found purpose. His quest for vengeance became something greater – a fight for justice, for freedom, for all of Italy.

The list of conspirators grew. Corrupt officials, greedy merchants, even men of the cloth – all were part of the Templar conspiracy. One by one, Ezio would find them. And one by one, they would fall to his blade.''',
          chapterNumber: 3,
        ),
      ],
    ),
    Book(
      id: '2',
      title: 'Bloodborne: The Death of Sleep',
      author: 'Ales Kot',
      coverImage: 'assets/img/bloodborne.jpg',
      description: 'A nameless hunter awakens in the plague-ridden city of Yharnam, where beasts roam the streets and the night of the hunt never ends. Death is not the end, but merely another beginning.',
      rating: 4.8,
      tags: ['Horror', 'Dark Fantasy', 'Gothic'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: Awakening',
          content: '''You wake with a start, lying on a cold stone floor. The scent of old blood fills your nostrils. Your head pounds with memories that aren't quite your own, or perhaps they are, but from a life you can't remember living.

A hunched figure looms over you in the dim candlelight. Its face is hidden behind bandages stained with crimson. "Ah, you've found yourself a hunter," it rasps, its voice like gravel scraping against stone.

You try to speak, but your throat is raw. The figure continues, seeming not to need a response. "You will hunt, and you will die. Die and hunt again. Such is the nature of the night of the hunt."

As your eyes adjust to the gloom, you see you're in a clinic of sorts. Strange medical equipment lines the walls, instruments whose purposes you can't fathom. Vials of dark liquid rest on nearby tables, and the floor is stained with substances you'd rather not identify.

"Seek Paleblood to transcend the hunt," the figure whispers, and then it's gone. Not walked away – simply gone, as if it had never been there at all.

You rise on unsteady legs. Nearby, you find simple hunter's garb and a small saw-like weapon. The moment your hand touches the weapon's grip, knowledge floods your mind. You know how to use this. You've always known.

Through a doorway, the streets of Yharnam await. The city is caught in eternal twilight, its Gothic spires reaching toward a sky that seems to press down with malevolent intent. In the distance, you hear howls that sound almost human.

The hunt begins.''',
          chapterNumber: 1,
        ),
        Chapter(
          id: 'c2',
          title: 'Chapter 2: The Night Grows Long',
          content: '''The streets of Central Yharnam twist and turn like the corridors of a nightmare. Lanterns burn with a sick, pale light that does little to push back the darkness. You move carefully, every sense alert.

Around a corner, you encounter your first beast. Once, it might have been human. Now, it's a twisted thing of matted fur and too many teeth. It sniffs the air, catching your scent, and turns its malformed head toward you.

Time seems to slow as it lunges. Your body moves instinctively, sidestepping the clumsy attack. Your saw-cleaver extends with a sharp CRACK, and you strike. The beast howls, more in rage than pain, and swipes at you with claws like rusted blades.

The fight is desperate, brutal, and short. When the beast finally falls, it seems to deflate, its flesh turning to ash that blows away on a wind you cannot feel. Where it fell, you find blood echoes – fragments of memory and strength that flow into you.

"Beasts all over the shop," a voice calls from a barred window above. "You'll be one of them, sooner or later."

You look up to see a face pale and drawn, eyes wide with fear and perhaps madness. Before you can respond, the shutter slams closed.

The deeper you venture into Yharnam, the more wrong everything feels. The architecture makes no sense, angles that shouldn't exist. Statues of strange beings that seem to watch you pass. And everywhere, the smell of blood and incense.

In a central square, you find other hunters. Or rather, their corpses. They're impaled on pikes, their faces frozen in expressions of horror. Hanging from one is a note: "The Paleblood sky awaits."

Above the city, the moon hangs huge and red, like a bloodshot eye watching everything below.''',
          chapterNumber: 2,
        ),
      ],
    ),
    Book(
      id: '3',
      title: 'Dark Souls: Age of Fire',
      author: 'George Mann',
      coverImage: 'assets/img/darksoul.jpg',
      description: 'In the Age of Fire, the world is held together by the linking of the flame. But the fire fades, darkness spreads, and the Undead curse claims more souls with each passing day.',
      rating: 4.6,
      tags: ['Dark Fantasy', 'Epic', 'Medieval'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: The Undead Asylum',
          content: '''You died. You remember that much. What you did before, who you were – those memories are fading like smoke. All that remains is the knowledge that you died, and yet you still exist.

The cell is small, damp, and dark. Iron bars separate you from a dim corridor lit by guttering torches. You are undead now, cursed to return each time death claims you, until your mind finally erodes and you become Hollow.

For how long you've been here, you cannot say. Time has no meaning in this place. Days? Years? Centuries? Other undead occupy nearby cells. Some moan mindlessly. Others sit in silence, already Hollow, their souls long consumed by despair.

Then, something unexpected. A body crashes through the ceiling of your cell, plummeting from somewhere high above. It's another undead, but this one moves with purpose. He rises, looks at you with eyes that still hold a spark of sanity.

"You're not Hollow yet," he says. "Good. I am Oscar of Astora. Listen well, for I have not much time." He coughs, and blood – black, not red – spills from his lips. "The mission falls to you now. Travel to Lordran, ring the Bells of Awakening. One above, in the Undead Parish. One below, in Blighttown. That is your quest."

He produces a key, which he slides through the bars to you. "My dying wish is that you succeed where I have failed. Don't give up. And, above all, don't you dare go Hollow."

With those words, Oscar of Astora collapses. When you unlock your cell and approach, you find only a corpse that crumbles to dust at your touch. But he leaves behind a gift – an Estus Flask, filled with liquid fire that can heal your wounds.

You take up his sword and his shield. Ahead lies the Asylum Demon, and beyond that, a world dying by inches, where Gods and Men struggle against the coming age of Dark.

Praise the sun, Oscar had whispered as his last words. You don't know what it means, but you'll remember.''',
          chapterNumber: 1,
        ),
      ],
    ),
    Book(
      id: '4',
      title: 'Dragon Age: The Stolen Throne',
      author: 'David Gaider',
      coverImage: 'assets/img/dragonage.jpg',
      description: 'Before the Blight, before the Grey Wardens, there was a prince who would be king. The story of how Maric won back his throne from the Orlesian occupation.',
      rating: 4.3,
      tags: ['Fantasy', 'Political', 'Adventure'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: The Prince in Exile',
          content: '''The rain fell in sheets across the Fereldan wilderness. Prince Maric stumbled through the mud, his fine clothes torn and stained, his crown lost somewhere in the chaos of the battlefield. Behind him, the ruins of his mother's army burned.

Queen Moira the Rebel had fallen. The Orlesian chevaliers had seen to that, their cavalry crushing the Fereldan resistance with contemptuous ease. Maric had watched his mother die, her standard trampling beneath foreign boots.

Now he ran, the last scion of House Theirin, with nothing but his life and a determination not to let his mother's sacrifice be in vain. The Orlesians had occupied Ferelden for years, bleeding the country dry, treating its people like animals. His mother had dared to fight back. And she had lost.

"Keep moving, your Highness," a gruff voice called. Loghain Mac Tir, his mother's best officer, appeared through the rain. The young warrior's face was grim, but his eyes burned with unquenched fury. "If they catch us now, everything she died for will be lost."

They were not alone. A few dozen survivors had rallied to them – the battered remnants of the rebel army. Farmers with pitchforks, merchants with stolen swords, a handful of knights who had lost their horses. This was all that remained of Ferelden's hope.

"Where can we go?" Maric asked, his voice hoarse. "The Orlesians control every major city. We have nothing."

"We have the one thing they can never take," Loghain replied, his jaw set. "We're Ferelden. This is our land. And we will fight for it until the last drop of blood is spent."

That night, huddled in the ruins of an old temple, Maric made a vow. He would reclaim his throne. He would drive the Orlesians from his homeland. He would avenge his mother.

It would take years. The path would be long and brutal, filled with unlikely alliances and painful betrayals. But Prince Maric would become King Maric. And Ferelden would be free.''',
          chapterNumber: 1,
        ),
      ],
    ),
    Book(
      id: '5',
      title: 'Elden Ring: The Road to the Erdtree',
      author: 'Anonymous Tarnished',
      coverImage: 'assets/img/eldenring.jpg',
      description: 'Rise, Tarnished, and be guided by grace to brandish the power of the Elden Ring and become an Elden Lord in the Lands Between.',
      rating: 4.9,
      tags: ['Fantasy', 'Epic', 'Mythology'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: The Lands Between',
          content: '''You awaken in a tomb, the grace of gold flickering in the darkness. Once, you were Tarnished – dead, exiled beyond the fog. Now, the Elden Ring is shattered, and grace calls to you once more.

The light guides your path upward, through ancient catacombs where the dead do not rest peacefully. Your hands find a simple sword, and knowledge flows into you. You are not merely undead. You are Tarnished, chosen to seek the Elden Ring and claim the title of Elden Lord.

When you finally emerge into daylight, the sight steals your breath. The Lands Between spread before you in terrible beauty. Golden trees catch the light, their leaves shimmering. But darkness spreads across the landscape like a cancer.

The Erdtree towers in the distance, visible from everywhere in this broken realm. Once, it was the source of all grace, all life. Now, its light flickers uncertainly. The Elden Ring that gave it power lies shattered, its Great Runes scattered among demigods gone mad with power.

A woman appears on a spectral steed, her face hidden by a hood. "I am Melina," she says. "I can play the role of maiden. Turning rune fragments into strength. To aid you in your search for the Elden Ring. Have we a deal?"

You nod. What choice do you have? Alone, you are nothing – another Tarnished who will fall to the first Grafted Scion or Soldier of Godrick. With her aid, perhaps you can survive.

"Then let us journey together," Melina says, and vanishes.

You're left standing in Limgrave, the starting point of every Tarnished's journey. Stormveil Castle looms ahead, home to Godrick the Grafted, first of the demigods you must face. But the world is vast, and grace points in many directions.

The golden sites of grace dot the landscape, each one a checkpoint, a moment of safety in a hostile world. You move toward the first one, ignoring the Tree Sentinel patrolling nearby. That enemy is far beyond you now.

The journey to become Elden Lord begins with a single step. And a thousand deaths.''',
          chapterNumber: 1,
        ),
      ],
    ),
    Book(
      id: '6',
      title: 'Metro 2033',
      author: 'Dmitry Glukhovsky',
      coverImage: 'assets/img/metro.jpg',
      description: 'The year is 2033. The world has been destroyed by nuclear war. Survivors hide in the tunnels of the Moscow Metro, and young Artyom must journey through the darkness to save his home station.',
      rating: 4.7,
      tags: ['Post-Apocalyptic', 'Sci-Fi', 'Horror'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: VDNKh',
          content: '''The Metro was all Artyom had ever known. Born just before the bombs fell, he had no memory of the world above, of blue skies and green grass. His world was tunnels and stations, darkness and the occasional flicker of electric light.

VDNKh station was home. Not a large station, not a rich one, but home nonetheless. Artyom knew every tunnel, every hiding spot, every face in the marketplace. He'd been raised by Sukhoi, the stalker who'd found him as a child in a ruined bunker on the surface.

Life in the Metro wasn't easy. Clean water was precious, bullets served as currency, and the air filters that kept you alive on the surface cost more than most could afford. But it was life, and people clung to it with desperate determination.

The tunnels between stations were another matter. Things lived in the darkness – mutants born from the radiation. Nosalises that hunted in packs, their eyeless faces sniffing for prey. Watchers that moved with terrible intelligence. And worse things, things that had no names.

Artyom stood guard duty that night, as he often did. The northern tunnel was quiet, the darkness absolute beyond the lights of the station. Too quiet, he thought. No echoes, no sounds of movement.

Then he heard it. A whistle, piercing and wrong, coming from the black. The signal of a stalker, calling for the gates to be opened. But something was off about it. Too high-pitched, too long.

Before Artyom could raise the alarm, they came. Nosalises, dozens of them, pouring from the tunnel in a tide of pale flesh and snapping jaws. The guard post erupted in gunfire, bullets precious but lives more so.

When the attack was finally beaten back and the last mutant lay dead, Hunter arrived. The legendary stalker had come to VDNKh with dire news. Something was driving the Dark Ones south, pushing them toward the inhabited stations. And VDNKh lay directly in their path.

"I'll go to Polis," Hunter said. "Warn the Council. If I don't return in two weeks, you must go yourself, Artyom. This threat is beyond any single station. All Metro must prepare."

Hunter disappeared into the northern tunnel, and Artyom returned to his room, wondering if he would ever see the legendary stalker again.

Two weeks later, with no sign of Hunter's return, Artyom made ready for a journey into the heart of the Metro itself.''',
          chapterNumber: 1,
        ),
      ],
    ),
    Book(
      id: '7',
      title: 'Sekiro: Shadows Die Twice',
      author: 'FromSoftware',
      coverImage: 'assets/img/sekiro.jpg',
      description: 'A disgraced shinobi rises from near-death to rescue his young lord from the hands of a dangerous clan. In a land where death is not always the end, revenge and loyalty drive him forward.',
      rating: 4.8,
      tags: ['Historical Fiction', 'Action', 'Japanese'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: The Wolf',
          content: '''They called him Sekiro – the one-armed wolf. Not always. Once, he had been merely Shinobi, a nameless warrior bound in service to the Divine Heir. But that was before his arm was taken, before his master was stolen, before his death and resurrection.

The memory was sharp as his katana. Genichiro Ashina, grandson of the sword-saint, standing over him with cold eyes. "Hand over your lord," Genichiro had demanded. "His blood is the key to Ashina's salvation."

Sekiro had refused, drawing his blade even knowing he was outmatched. The duel had been brutal and quick. Genichiro's lightning-fast strikes had overwhelmed him, and the final blow had sent Sekiro plummeting from the castle tower, his arm severed, his lord torn from his grasp.

He should have died. By every law of nature, falling from that height with such wounds, death was certain. And death did come. He felt it – the cold embrace, the darkness closing in.

But then, light. The Sculptor's temple. He awoke on a stone floor, his left arm ending in a stump but alive. Impossibly, inexplicably alive.

"The Dragon's Heritage," the Sculptor explained, his own arm replaced by a crude prosthetic. "Your lord carries it in his blood. Those who serve him cannot truly die while he lives. But each death carries a cost. A burden that will spread to others."

The Sculptor fitted Sekiro with a similar prosthetic – but this one was no simple replacement. It was a shinobi tool, capable of housing various mechanisms. A grappling hook, allowing him to scale walls and close distances with impossible speed. And other things, waiting to be discovered.

"Go," the Sculptor said. "Reclaim your lord. But remember – death has consequences. Dragonrot will spread with each resurrection. Those around you will sicken. Your quest puts all at risk."

Sekiro rose, testing his new arm. It moved like a natural limb, the grappling hook deploying with a thought. He looked toward Ashina Castle in the distance, where Genichiro held the Divine Heir captive.

He had died once. He would die again, many times. But each death would make him stronger. He would learn his enemies' every move, would master the dance of blade against blade. And he would not stop until his lord was free.

The wolf would have his revenge.''',
          chapterNumber: 1,
        ),
      ],
    ),
    Book(
      id: '8',
      title: 'The Elder Scrolls: Skyrim',
      author: 'Bethesda',
      coverImage: 'assets/img/skyrim.jpg',
      description: 'Dragons have returned to Skyrim. The fate of the world hangs in the balance as the Dragonborn rises to face Alduin the World-Eater and fulfill an ancient prophecy.',
      rating: 4.7,
      tags: ['Fantasy', 'Epic', 'Norse Mythology'],
      chapters: [
        Chapter(
          id: 'c1',
          title: 'Chapter 1: Dragonborn',
          content: '''The cart rattled along the mountain road, carrying its load of prisoners toward their execution. You sat among them, hands bound, uncertain how you'd ended up here. The Empire's soldiers had caught you crossing the border – wrong place, wrong time.

"Hey, you. You're finally awake," said the horse thief across from you. "You were trying to cross the border, right? Walked right into that Imperial ambush."

Beside you sat Ulfric Stormcloak, Jarl of Windhelm, gagged and bound. His capture was the real prize. You were just collateral damage in a civil war you didn't understand.

The cart rolled into Helgen, a small town pressed against the mountains. The town square had been converted into an executioner's stage. A block, an axe, and a basket for heads.

"I'm sorry," whispered the priestess. "At least you'll die here, in your homeland."

But you weren't from here. You weren't from anywhere, as far as you could remember. Just a wanderer who'd been in the wrong place.

As the first prisoner knelt before the block and the axe began to fall, a sound split the sky. A roar, primal and terrible. The executioner paused, looking up.

"What was that?" a soldier muttered.

Then the world exploded. A massive shape descended from the sky, scales black as midnight, wings blotting out the sun. A dragon – but dragons were extinct, dead for thousands of years. Yet here one was, very much alive, and breathing fire.

"Dragon!" someone screamed. "Everyone, get back!"

The town erupted into chaos. Buildings caught fire. Soldiers scattered. The dragon perched atop the tower, its eyes burning with ancient hatred. When it opened its mouth and spoke, the words were in a language no one had heard for eons, yet somehow you understood them.

"YOL TOOR SHUL!" The Thu'um – the Voice. Fire washed across the square.

In the chaos, your bonds were forgotten. You ran, following a soldier into a building. Behind you, Helgen burned. Before you lay Skyrim, vast and dangerous, a land torn by civil war and now plagued by the return of dragons.

You didn't know it yet, but you were special. When the dragon had spoken, you had understood. And soon, you would speak back, your Voice shaking the mountains. You were Dragonborn, the one prophesied to stand against Alduin the World-Eater.

But first, you had to survive this day.''',
          chapterNumber: 1,
        ),
      ],
    ),
  ];

  // For favorite and read books tracking
  final Set<String> _favoriteBookIds = {};
  final Set<String> _readBookIds = {};

  List<Book> get allBooks => List.unmodifiable(_books);
  
  void addBook(Book book) {
    _books.add(book);
  }

  void updateBook(Book book) {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
    }
  }

  void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
    _favoriteBookIds.remove(id);
    _readBookIds.remove(id);
  }
  
  List<Book> get favoriteBooks => 
      _books.where((book) => _favoriteBookIds.contains(book.id)).toList();
  
  List<Book> get readBooks => 
      _books.where((book) => _readBookIds.contains(book.id)).toList();

  bool isFavorite(String bookId) => _favoriteBookIds.contains(bookId);
  bool isRead(String bookId) => _readBookIds.contains(bookId);

  void toggleFavorite(String bookId) {
    if (_favoriteBookIds.contains(bookId)) {
      _favoriteBookIds.remove(bookId);
    } else {
      _favoriteBookIds.add(bookId);
    }
    _saveFavorites();
  }

  void markAsRead(String bookId) {
    _readBookIds.add(bookId);
    _saveReadBooks();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteBookIds.toList());
  }

  Future<void> _saveReadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_books', _readBookIds.toList());
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    final readBooks = prefs.getStringList('read_books') ?? [];
    
    _favoriteBookIds.addAll(favorites);
    _readBookIds.addAll(readBooks);
  }

  List<Book> searchBooks(String query) {
    if (query.isEmpty) return allBooks;
    
    query = query.toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  List<Book> filterByTags(List<String> tags) {
    if (tags.isEmpty) return allBooks;
    
    return _books.where((book) {
      return book.tags.any((tag) => tags.contains(tag));
    }).toList();
  }

  Book? getBookById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (var book in _books) {
      tags.addAll(book.tags);
    }
    return tags.toList()..sort();
  }
}
