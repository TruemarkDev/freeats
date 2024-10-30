# frozen_string_literal: true

# This logic comes from selectize score function.
class SelectComponent::Score < ApplicationOperation
  include Dry::Monads[:result]

  option :text, Types::Strict::String
  option :query, Types::Strict::String

  def call
    string_for_regex = Regexp.escape(query).chars.map { |letter| DIACRITICS[letter] || letter }.join
    regex = /#{string_for_regex}/i

    index = text.index(regex)
    return Success(0) if index.nil?

    score = query.size / text.size.to_f
    score += 0.5 if index.zero?

    Success(score)
  end

  DIACRITICS = {
    "a" => "[aḀḁĂăÂâǍǎȺⱥȦȧẠạÄäÀàÁáĀāÃãÅåąĄÃąĄ]",
    "b" => "[b␢βΒB฿𐌁ᛒ]",
    "c" => "[cĆćĈĉČčĊċC̄c̄ÇçḈḉȻȼƇƈɕᴄＣｃ]",
    "d" => "[dĎďḊḋḐḑḌḍḒḓḎḏĐđD̦d̦ƉɖƊɗƋƌᵭᶁᶑȡᴅＤｄð]",
    "e" => "[eÉéÈèÊêḘḙĚěĔĕẼẽḚḛẺẻĖėËëĒēȨȩĘęᶒɆɇȄȅẾếỀềỄễỂểḜḝḖḗḔḕȆȇẸẹỆệⱸᴇＥｅɘǝƏƐε]",
    "f" => "[fƑƒḞḟ]",
    "g" => "[gɢ₲ǤǥĜĝĞğĢģƓɠĠġ]",
    "h" => "[hĤĥĦħḨḩẖẖḤḥḢḣɦʰǶƕ]",
    "i" => "[iÍíÌìĬĭÎîǏǐÏïḮḯĨĩĮįĪīỈỉȈȉȊȋỊịḬḭƗɨɨ̆ᵻᶖİiIıɪＩｉ]",
    "j" => "[jȷĴĵɈɉʝɟʲ]",
    "k" => "[kƘƙꝀꝁḰḱǨǩḲḳḴḵκϰ₭]",
    "l" => "[lŁłĽľĻļĹĺḶḷḸḹḼḽḺḻĿŀȽƚⱠⱡⱢɫɬᶅɭȴʟＬｌ]",
    "n" => "[nŃńǸǹŇňÑñṄṅŅņṆṇṊṋṈṉN̈n̈ƝɲȠƞᵰᶇɳȵɴＮｎŊŋ]",
    "o" => "[oØøÖöÓóÒòÔôǑǒŐőŎŏȮȯỌọƟɵƠơỎỏŌōÕõǪǫȌȍՕօ]",
    "p" => "[pṔṕṖṗⱣᵽƤƥᵱ]",
    "q" => "[qꝖꝗʠɊɋꝘꝙq̃]",
    "r" => "[rŔŕɌɍŘřŖŗṘṙȐȑȒȓṚṛⱤɽ]",
    "s" => "[sŚśṠṡṢṣꞨꞩŜŝŠšŞşȘșS̈s̈]",
    "t" => "[tŤťṪṫŢţṬṭƮʈȚțṰṱṮṯƬƭ]",
    "u" => "[uŬŭɄʉỤụÜüÚúÙùÛûǓǔŰűŬŭƯưỦủŪūŨũŲųȔȕ∪]",
    "v" => "[vṼṽṾṿƲʋꝞꝟⱱʋ]",
    "w" => "[wẂẃẀẁŴŵẄẅẆẇẈẉ]",
    "x" => "[xẌẍẊẋχ]",
    "y" => "[yÝýỲỳŶŷŸÿỸỹẎẏỴỵɎɏƳƴ]",
    "z" => "[zŹźẐẑŽžŻżẒẓẔẕƵƶ]"
  }.freeze

  private_constant :DIACRITICS
end
