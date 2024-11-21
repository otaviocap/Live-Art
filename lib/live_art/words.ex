defmodule LiveArt.Words do
  def get_random_word() do
    [word] = Enum.take_random([
      "Caneta", "Lápis", "Livro", "Relógio", "Óculos", "Guarda", "Bolsa", "Mala", "Celular", "Tesoura",
      "Gato", "Cachorro", "Cavalo", "Elefante", "Leão", "Girafa", "Coelho", "Tartaruga", "Jacaré", "Urso",
      "Árvore", "Flor", "Montanha", "Sol", "Lua", "Estrela", "Arco", "Nuvem", "Oceano", "Vulcão",
      "Maçã", "Banana", "Melancia", "Pizza", "Hambúrguer", "Sorvete", "Bolo", "Batata", "Ovo", "Pão",
      "Carro", "Moto", "Bicicleta", "Caminhão", "Barco", "Avião", "Helicóptero", "Trem", "Skate", "Patins",
      "Bombeiro", "Médico", "Professor", "Jogador", "Artista", "Policial", "Pintor", "Cantor", "Cozinheiro", "Agricultor",
      "Futebol", "Basquete", "Tênis", "Natação", "Vôlei", "Corrida", "Golfe", "Esqui", "Surf", "Skateboard",
      "Dragão", "Fada", "Bruxa", "Mago", "Sereia", "Unicórnio", "Zumbi", "Vampiro", "Monstro", "Fantasma",
      "Computador", "Televisão", "Microfone", "Roda", "Drone", "Teclado", "Controle", "Aspirador", "Impressora", "Fone",
      "Natal", "Ano", "Páscoa", "Aniversário", "Carnaval", "Halloween", "Casamento", "Formatura", "Festa", "Ceia",
      "Camiseta", "Calça", "Vestido", "Chapéu", "Sapato", "Meias", "Gravata", "Blusa", "Saia", "Jaqueta",
      "Praia", "Cinema", "Escola", "Mercado", "Parque", "Biblioteca", "Hospital", "Restaurante", "Shopping", "Estádio",
      "Cama", "Sofá", "Mesa", "Cadeira", "Armário", "Geladeira", "Fogão", "Espelho", "Televisão", "Chuveiro",
      "Relâmpago", "Chuva", "Neve", "Vento", "Tempestade", "Tornado", "Onda", "Lago", "Deserto", "Floresta",
      "Balão", "Pipa", "Karaoke", "Palhaço", "Piscina", "Escorregador", "Montanha", "Labirinto", "Trampolim", "Castelo",
      "Abelha", "Borboleta", "Peixe", "Águia", "Cobra", "Pato", "Cavalo", "Tigre", "Pinguim", "Canguru",
      "Lâmpada", "Abajur", "Candelabro", "Lanterna", "Velas", "Fogueira", "Holofote", "Luminária", "Lanterna", "Facho"
    ],1)

    word
  end
end
