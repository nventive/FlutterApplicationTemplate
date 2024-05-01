import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';

import 'dad_jokes_data_mock.dart';

List<DadJokeContentData> getDadJokesList() {
  return mockedDadJokeResponse.dadJokeData.dadJokeChildrenData
      .map(
        (joke) => (joke.dadJokeContentData),
      )
      .toList();
}

List<DadJokeContentData> getFavoriteDadJokesList() {
  return [
    const DadJokeContentData(
      id: "1cccv3s",
      title: 'As I handed my Dad his 50th birthday card, he looked at me with tears in his eyes and said,',
      selfText: '"You know, one would have been enough."',
    ),
    const DadJokeContentData(
      id: "1cc5169",
      title: 'I guess I really am getting old and out of touch. I walked by a rally the other day and saw a lovely young girl shouting "They\'re all bastards!" I said "My word! Who?" She said the police. I was shocked.',
      selfText: 'I mean I never cared for Sting myself, but the other two guys were just lovely',
    ),
  ];
}
