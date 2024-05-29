import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:app/access/dad_jokes/mocks/dad_jokes_data_mock.dart';

List<DadJokeContentData> getMockedDadJokesList() {
  return mockedDadJokeResponse.dadJokeData.dadJokeChildrenData
      .map(
        (joke) => (joke.dadJokeContentData),
      )
      .toList();
}

List<DadJokeContentData> getMockedFavoriteDadJokesList() {
  return [
    const DadJokeContentData(
      id: "17urj7q",
      title: 'My wife just completed a 40 week body building program this morning',
      selfText: '"It\'s a girl and weighs 7lbs 12 oz."',
    ),
  ];
}
