//
//  ScoreCardView.swift
//  Coach
//
//  Created by Stephen Bensley on 7/19/24.
//

import SwiftUI

struct ScoreColumn<Content>: View where Content: View {
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .frame(width: 510, height: 1215)
        .background(
            GridLines(rowCount: 9, columnWidths: [120.0, 50.0])
                .stroke(lineWidth: 3.0)
            )
    }
}

struct ScoreItem: View {
    let title: LocalizedStringKey
    let points: Int?
    private var pointsAsString: String { points?.description ?? "" }
    
    init(_ title: LocalizedStringKey, _ points: Int?) {
        self.title = title
        self.points = points
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .padding(20)
                .frame(width: 360, height: 135, alignment: .leading)
                .font(.custom("Futura-Medium", size: 50))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            Text(pointsAsString)
                .padding(20)
                .frame(width: 150, height: 135, alignment: .trailing)
                .font(.custom("ChalkboardSE-Regular", size: 60))
                .foregroundStyle(Color(red: 92.0/255.0, green: 98.0/255.0, blue: 116.0/255.0))
          }

    }
}

struct ScoreCard: View {
    var body: some View {
        VStack {
            HStack {
                  Text("Yatzy")
                    .font(.custom("MarkerFelt-wide", size: 85))
                    .baselineOffset(17)
                    .padding(.trailing, 12.0)
                 Text("SCORE CARD")
                    .font(.custom("Futura-Medium", size: 70))
                }
            .padding(.bottom, 40)
            
            HStack(spacing: 30) {
                ScoreColumn {
                    ScoreItem("Aces", nil)
                    ScoreItem("Twos", 10)
                    ScoreItem("Threes", nil)
                    ScoreItem("Fours", 20)
                    ScoreItem("Fives", 10)
                    ScoreItem("Sixes", nil)
                    ScoreItem("*Total*", 40)
                    ScoreItem("*Bonus*", nil)
                    ScoreItem("***Upper Total***", 40)
                }
                ScoreColumn {
                    ScoreItem("3 of a kind", nil)
                    ScoreItem("4 of a kind", 10)
                    ScoreItem("Full House", nil)
                    ScoreItem("Sm. Straight", 20)
                    ScoreItem("Lg. Straight", 10)
                    ScoreItem("Yatzy", nil)
                    ScoreItem("Chance", 40)
                    ScoreItem("*Lower Total*", nil)
                    ScoreItem("**GRAND TOTAL**", 40)
                }
            }
        }
        .frame(width: 1110, height: 1500)
        .background(.white)
    }
        
}

#Preview {
    ScoreCard()
        .scaleEffect(1.0/3.0)
}
