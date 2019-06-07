#pragma once
#include <clients/common/FluidBaseClient.hpp>
#include <nlohmann/json.hpp>
#include <array>
#include <fstream>
#include <string>
#include <utility>


// for convenience
using json = nlohmann::json;

namespace fluid {
namespace client {

template<typename C> struct Constraint;

template<>
struct Constraint<EnumT::EnumConstraint>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const EnumT::EnumConstraint&, Tuple&) { return {"Enum",true}; }
};

template<int MaxFFT>
struct Constraint<FFTParams::FFTSettingsConstraint<MaxFFT>>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const FFTParams::FFTSettingsConstraint<MaxFFT>&, Tuple&) { return {"MaxFFT", MaxFFT > -1 }; }
};


template<typename T>
struct Constraint<impl::MinImpl<T>>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const impl::MinImpl<T>& c, Tuple&) { return {"min", c.value}; }
};

template<typename T>
struct Constraint<impl::MaxImpl<T>>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const impl::MaxImpl<T>& c,Tuple&) { return {"max", c.value}; }
};

template<int...Is, typename Tuple>
std::array<const char*,sizeof...(Is)> relations(Tuple& params)
{
  return {{std::get<0>(std::get<Is>(params)).name...}};
}

template<int...Is>
struct Constraint<impl::UpperLimitImpl<Is...>>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const impl::UpperLimitImpl<Is...>&,Tuple& params)
  {  return {"upper", relations<Is...>(params)}; }
};

template<int...Is>
struct Constraint<impl::LowerLimitImpl<Is...>>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const impl::LowerLimitImpl<Is...>&, Tuple& params) { return {"lower", relations<Is...>(params)}; }
};

template<int I>
struct Constraint<impl::FrameSizeUpperLimitImpl<I>>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const impl::FrameSizeUpperLimitImpl<I>&,Tuple&) { return {"upper","fftFrame"};}
};

template<int I>
struct Constraint<impl::MaxFrameSizeUpperLimitImpl<I>>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const impl::MaxFrameSizeUpperLimitImpl<I>&,Tuple&) { return {"upper","maxFFTFrame"};}
};


template<>
struct Constraint<Odd>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const Odd&,Tuple&) { return {"snap","odd"}; }
};

template<>
struct Constraint<PowerOfTwo>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const PowerOfTwo&,Tuple&) { return {"snap", "powerTwo"}; }
};

template<>
struct Constraint<FrequencyAmpPairConstraint>
{
  template<typename Tuple>
  static json::object_t::value_type dump(const FrequencyAmpPairConstraint&,Tuple&) { return {"FreqAmpPair","true"}; }
};

void to_json(json& j, const FFTParams& p)
{
    j = json::array({{"winSize", p.winSize()}, {"hopSize", p.hopRaw()}, {"fftSize", p.fftRaw()}});
}

void to_json(json& j, const FloatPairsArrayT::FloatPairsArrayType& p)
{
    j = json{{"value", p.value}};
}

template <template<typename>class T>
class ParameterDump
{
public:
  using  Params = typename T<double>::ParamDescType;

  static void dump(std::string ofile,std::string prefix)
  {
    json j = dumpImpl(typename Params::IndexList());
//    std::string cwd(getcwd(nullptr,0));
    std::ofstream(prefix + ofile + ".json") << j.dump(2) << '\n';
  }

  template<size_t...Is>
  static json dumpImpl(std::index_sequence<Is...>)
  {
    Params& p = T<double>::getParameterDescriptors();
    json j = json::array({jsonify(std::get<Is>(p.descriptors()), p.descriptors())...});
    return j;
  }

  template<size_t...Is, typename C, typename P>
  static json constraints(const C& constraints, std::index_sequence<Is...>, P& allParams)
  {
    json res = json::object();
    (void)std::initializer_list<int>{(res.push_back(Constraint<typename std::tuple_element<Is,C>::type>::dump(std::get<Is>(constraints),allParams)),0)...};
    return res;
  }

  template<typename P,typename All>
  static json::object_t::value_type jsonify(P& param, All& allParams)
  {

      return jsonify_param(std::get<0>(param), param, allParams);
  }

  static std::string getParamType(const BufferT&) { return "buffer"; }
  static std::string getParamType(const FloatT&) { return "float"; }
  static std::string getParamType(const LongT&) { return "long"; }
  static std::string getParamType(const FloatPairsArrayT&) { return "float";}

  template<typename P,typename Tuple, typename All>
  static json::object_t::value_type jsonify_param(P& p, Tuple& tuple, All& allParams)
  {
    constexpr bool fixed = std::tuple_element<2,Tuple>::type::value;
    json j;
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = fixed;
    j["type"] = getParamType(p);
    j["size"] = p.fixedSize;

    auto& constraintsTuple = std::get<1>(tuple);
    using constraintsTupleType = std::decay_t<decltype(constraintsTuple)>;
    constexpr size_t numConstraints = std::tuple_size<constraintsTupleType>::value;
    if(numConstraints > 0)
    {
      auto constraintsIndex = std::make_index_sequence<numConstraints>();
      auto c = constraints(constraintsTuple,constraintsIndex,allParams);
      if(c.type() != json::value_t::null) j["constraints"] = c;
    }
//    std::cout << j.dump(2) << '\n';
    return {p.name,j};
  }


  template<typename Tuple, typename All>
  static json::object_t::value_type jsonify_param(const EnumT& p, Tuple&, All&)
  {
    json j;
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = false;
    std::vector<std::string> strings(p.numOptions);
    std::copy(p.strings, p.strings + p.numOptions,strings.begin());
    j["values"] = strings;
//    std::cout << j.dump(2) << '\n';
    return {p.name,j};
  }

  template<typename Tuple, typename All>
  static json::object_t::value_type jsonify_param(const FFTParamsT& p, Tuple&, All&)
  {
    json j;
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = false;
    j["size"] = 3;
    j["type"] = "long";
//    std::cout << j.dump(2) << '\n';
    return {p.name,j};
  }
};
}
}
