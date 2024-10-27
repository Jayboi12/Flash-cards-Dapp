import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Option "mo:base/Option";

actor {
    type Flashcard = {
        id: Nat;
        front: Text;
        back: Text;
        difficulty: Nat; // 1: Easy, 2: Medium, 3: Hard
        language: Text;
    };

    private var nextId: Nat = 0;
    private var cards = HashMap.HashMap<Nat, Flashcard>(0, Nat.equal, Hash.hash);

    public func createCard(front: Text, back: Text, difficulty: ?Nat, language: ?Text) : async Nat {
        let id = nextId;
        let newCard: Flashcard = {
            id;
            front;
            back;
            difficulty = Option.get(difficulty, 2); // Default to Medium if not provided
            language = Option.get(language, "General"); // Default to "General" if not provided
        };
        cards.put(id, newCard);
        nextId += 1;
        id
    };

    public func updateCard(id: Nat, front: ?Text, back: ?Text, difficulty: ?Nat, language: ?Text) : async Bool {
        switch (cards.get(id)) {
            case (null) { false };
            case (?existingCard) {
                let updatedCard: Flashcard = {
                    id = existingCard.id;
                    front = Option.get(front, existingCard.front);
                    back = Option.get(back, existingCard.back);
                    difficulty = Option.get(difficulty, existingCard.difficulty);
                    language = Option.get(language, existingCard.language);
                };
                cards.put(id, updatedCard);
                true
            };
        }
    };

    public query func getCard(id: Nat) : async ?Flashcard {
        cards.get(id)
    };

    public query func getAllCards() : async [Flashcard] {
        Iter.toArray(cards.vals())
    };

    public query func getCardsByDifficulty(difficulty: Nat) : async [Flashcard] {
        Array.filter<Flashcard>(Iter.toArray(cards.vals()), func(card: Flashcard) : Bool {
            card.difficulty == difficulty
        })
    };

    public query func getCardsByLanguage(language: Text) : async [Flashcard] {
        Array.filter<Flashcard>(Iter.toArray(cards.vals()), func(card: Flashcard) : Bool {
            card.language == language
        })
    };

    public func deleteCard(id: Nat) : async Bool {
        switch (cards.remove(id)) {
            case (null) { false };
            case (?_) { true };
        }
    };
}