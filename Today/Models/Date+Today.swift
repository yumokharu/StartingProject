//
//  Date+Today.swift
//  Today
//
//  Created by 차유민 on 2023/05/06.
//

import Foundation

extension Date {
    var dayAndTimeText: String {
        let timeText = formatted(date: .omitted, time: .shortened)
        // 시간의 문자열 표현을 만들고 결과를 지정된 상수 timeText에 할당하기 위한 코드
        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
            // timeText에 timeFormat을 적용하여 문자열을 만들고 결과를 반환한다.
        } else {
            let dateText = formatted(.dateTime.month(.abbreviated).day())
            // 날짜의 문자열 표현을 만들고 결과를 상수 이름 dateText에 할당
            let dateAneTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format string")
            return String(format: dateAneTimeFormat, dateText, timeText)
            // 이제 계산된 속성이 로케일 인식 형식으로 날짜와 시간을 나타낸다.
            // else 뒤부터 써진 코드 : 제공된 날짜가 현재 달력의 날짜가 아닐 때 Foundation 프레임워크에 있는 formatted(date:time:) 을 사용하여 문자열을 만든다.
        }
    }
    var dayText: String {
        if Locale.current.calendar.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today due datd description")
        } else {
            return formatted(.dateTime.month().day().weekday(.wide))
        }
    }
}
